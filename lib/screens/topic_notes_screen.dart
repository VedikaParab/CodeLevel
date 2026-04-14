import 'package:flutter/material.dart';
import '../services/notes_service.dart';

class TopicNotesScreen extends StatefulWidget {
  final String topicTitle;
  final String language;
  final String level;
  final String notesContent;
  final String audioUrl;
  final String aiFetchedContent;

  const TopicNotesScreen({
    super.key,
    required this.topicTitle,
    required this.language,
    required this.level,
    required this.notesContent,
    required this.audioUrl,
    required this.aiFetchedContent,
  });

  @override
  State<TopicNotesScreen> createState() => _TopicNotesScreenState();
}

class _TopicNotesScreenState extends State<TopicNotesScreen> {
  late final NotesService _notesService;
  late Future<Map<String, dynamic>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _notesFuture = _fetchNotes();
  }

  Future<Map<String, dynamic>> _fetchNotes() {
    return _notesService.generateNotes(
      language: widget.language,
      level: _capitalize(widget.level),
      topic: widget.topicTitle,
    );
  }

  @override
  void dispose() {
    _notesService.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildList(List<dynamic> values) {
    if (values.isEmpty) {
      return const Text('No items available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• ${value.toString()}'),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCodeExamples(List<dynamic> examples) {
    if (examples.isEmpty) {
      return const Text('No code examples available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: examples.map((item) {
        final example = item is Map ? item : <String, dynamic>{};
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (example['description'] ?? '').toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text((example['code'] ?? '').toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleTopicView(Map<String, dynamic> data) {
    final codeExamples = data['code_examples'] is List
        ? data['code_examples'] as List
        : <dynamic>[];
    final keyPoints = data['key_points'] is List
        ? data['key_points'] as List
        : <dynamic>[];
    final commonMistakes = data['common_mistakes'] is List
        ? data['common_mistakes'] as List
        : <dynamic>[];
    final interviewQuestions = data['interview_questions'] is List
        ? data['interview_questions'] as List
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((data['overview'] ?? widget.notesContent).toString()),
        _buildSectionTitle('Definition'),
        Text((data['definition'] ?? '').toString()),
        _buildSectionTitle('Detailed Explanation'),
        Text((data['detailed_explanation'] ?? '').toString()),
        _buildSectionTitle('Syntax'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text((data['syntax'] ?? '').toString()),
        ),
        _buildSectionTitle('Code Examples'),
        _buildCodeExamples(codeExamples),
        _buildSectionTitle('Key Points'),
        _buildList(keyPoints),
        _buildSectionTitle('Common Mistakes'),
        _buildList(commonMistakes),
        _buildSectionTitle('Interview Questions'),
        _buildList(interviewQuestions),
      ],
    );
  }

  Widget _buildSubtopicsView(Map<String, dynamic> data) {
    final subtopics = data['subtopics'] is List
        ? data['subtopics'] as List
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((data['overview'] ?? '').toString()),
        const SizedBox(height: 12),
        ...subtopics.map((item) {
          final subtopic = item is Map ? item : <String, dynamic>{};
          final codeExamples = subtopic['code_examples'] is List
              ? subtopic['code_examples'] as List
              : <dynamic>[];
          final advantages = subtopic['advantages'] is List
              ? subtopic['advantages'] as List
              : <dynamic>[];
          final limitations = subtopic['limitations'] is List
              ? subtopic['limitations'] as List
              : <dynamic>[];
          final commonMistakes = subtopic['common_mistakes'] is List
              ? subtopic['common_mistakes'] as List
              : <dynamic>[];
          final examPoints = subtopic['exam_points'] is List
              ? subtopic['exam_points'] as List
              : <dynamic>[];
          final interviewQuestions = subtopic['interview_questions'] is List
              ? subtopic['interview_questions'] as List
              : <dynamic>[];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (subtopic['subtopic_title'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSectionTitle('Definition'),
                Text((subtopic['definition'] ?? '').toString()),
                _buildSectionTitle('Intuition'),
                Text((subtopic['intuition'] ?? '').toString()),
                _buildSectionTitle('Detailed Explanation'),
                Text((subtopic['detailed_explanation'] ?? '').toString()),
                _buildSectionTitle('Syntax'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text((subtopic['syntax'] ?? '').toString()),
                ),
                _buildSectionTitle('Code Examples'),
                _buildCodeExamples(codeExamples),
                _buildSectionTitle('Advantages'),
                _buildList(advantages),
                _buildSectionTitle('Limitations'),
                _buildList(limitations),
                _buildSectionTitle('Common Mistakes'),
                _buildList(commonMistakes),
                _buildSectionTitle('Exam Points'),
                _buildList(examPoints),
                _buildSectionTitle('Interview Questions'),
                _buildList(interviewQuestions),
              ],
            ),
          );
        }),
        if ((data['summary'] ?? '').toString().isNotEmpty) ...[
          _buildSectionTitle('Summary'),
          Text((data['summary'] ?? '').toString()),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _notesFuture = _fetchNotes();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? <String, dynamic>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.language} • ${_capitalize(widget.level)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 16),
                if (data['subtopics'] is List)
                  _buildSubtopicsView(data)
                else
                  _buildSingleTopicView(data),
                _buildSectionTitle('Audio'),
                Text(
                  widget.audioUrl.isNotEmpty
                      ? 'Play audio from: ${widget.audioUrl}'
                      : 'No audio available',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
