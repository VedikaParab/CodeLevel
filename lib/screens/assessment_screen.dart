import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/assessment_question.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final String language;
  final String level;
  final String topic;

  const AssessmentScreen({
    super.key,
    required this.language,
    required this.level,
    required this.topic,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  static const _endpoint = 'https://lvo38ogose.execute-api.ap-south-1.amazonaws.com/generate-assessment';

  List<AssessmentQuestion> _questions = [];
  bool _loading = true;
  String? _error;

  int _currentIndex = 0;
  int? _selectedIndex;
  int _score = 0;
  Timer? _timer;
  double _remaining = 20.0; // seconds
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({
      'language': widget.language,
      'level': widget.level,
      'topic': widget.topic,
    });

    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      if (data == null || data['questions'] == null) {
        throw Exception('Invalid response format');
      }

      final list = (data['questions'] as List).map((e) => AssessmentQuestion.fromJson(e as Map<String, dynamic>)).toList();
      // Limit to 5 questions as required
      final limited = list.length > 5 ? list.sublist(0, 5) : list;

      if (mounted) {
        setState(() {
          _questions = limited;
          _loading = false;
        });
        _startTimer();
      }
    } on TimeoutException catch (_) {
      if (mounted) setState(() { _error = 'Request timed out'; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onOptionSelected(int index) {
    if (_questions.isEmpty) return;
    final current = _questions[_currentIndex];
    if (index == current.correctIndex) _score++;

    if (_currentIndex >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _score,
          total: _questions.length,
          language: widget.language,
          level: widget.level,
          topic: widget.topic,
        ),
      ));
    } else {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = 20.0;
    _answered = false;
    _selectedIndex = null;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      setState(() {
        _remaining -= 0.1;
        if (_remaining <= 0) {
          t.cancel();
          _onTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    if (!mounted) return;
    setState(() {
      _answered = true;
      _selectedIndex = null; // no selection
    });
  }

  // Backwards-compatible wrapper used by existing UI
  Future<void> _loadQuestions() async => _fetchQuestions();

  // Called from option tap in the UI
  void _onOptionTap(int index) {
    if (_questions.isEmpty || _answered) return;
    _timer?.cancel();
    final current = _questions[_currentIndex];
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == current.correctIndex) _score++;
    });
  }

  void _onNext() {
    // Move to next question or finish
    _timer?.cancel();
    if (_currentIndex >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _score,
          total: _questions.length,
          language: widget.language,
          level: widget.level,
          topic: widget.topic,
        ),
      ));
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _answered = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F1115);
    final cardColor = const Color(0xFF15171B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Assessment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Error: $_error',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadQuestions,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  )
                : _buildQuiz(context, cardColor),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, Color cardColor) {
    final q = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Score: $_score',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar + timer
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_remaining.clamp(0.0, 20.0)) / 20.0,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_remaining.ceil()}s',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  q.question,
                  key: ValueKey<String>(q.question + _currentIndex.toString()),
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, i) {
                // Determine option color based on answer state
                Color bgColor = cardColor;
                Color textColor = Colors.white70;
                if (_answered) {
                  if (i == q.correctIndex) {
                    bgColor = Colors.green.withOpacity(0.18);
                    textColor = Colors.greenAccent.shade100;
                  } else if (_selectedIndex == i && _selectedIndex != q.correctIndex) {
                    bgColor = Colors.red.withOpacity(0.18);
                    textColor = Colors.redAccent.shade100;
                  }
                } else if (_selectedIndex == i) {
                  bgColor = Colors.blueAccent.withOpacity(0.18);
                  textColor = Colors.white;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () => _onOptionTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_answered && i == q.correctIndex)
                              ? Colors.greenAccent
                              : (_selectedIndex == i ? Colors.blueAccent : Colors.transparent),
                          width: 1.6,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          q.options[i],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Explanation + Next button
          if (_answered) ...[
            const SizedBox(height: 12),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  q.explanation,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex >= _questions.length - 1 ? 'Finish' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
          ]
        ],
      ),
    );
  }
}
