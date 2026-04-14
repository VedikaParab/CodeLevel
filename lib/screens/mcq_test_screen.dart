import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';

class McqTestScreen extends StatefulWidget {
  const McqTestScreen({super.key});

  @override
  State<McqTestScreen> createState() => _McqTestScreenState();
}

class _McqTestScreenState extends State<McqTestScreen> {
  int? _selectedOptionIndex;
  bool _isSubmitted = false;

  final List<String> _options = [
    'for i in range(5): print(i)',
    'for i in range(1,5): print(i)',
    'for i in 5: print(i)',
    'while i < 5: print(i)'
  ];

  final int _correctIndex = 0;

  void _submitAnswer() {
    if (_selectedOptionIndex != null) {
      setState(() {
        _isSubmitted = true;
      });
      // Show bottom sheet after brief delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _showExplanationSheet();
      });
    }
  }

  void _showExplanationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          borderColor: AppColors.accentGreen.withValues(alpha: 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.checkCircle2, color: AppColors.accentGreen, size: 28),
                  SizedBox(width: 12),
                  Text('Excellent!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '✓ range(5) generates 0, 1, 2, 3, 4 — it starts at 0 by default.',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Next Question',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Logic Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '240 pts',
                style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Counter
              Center(
                child: Text('Q 3 of 10', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              
              // Question Card
              GlassContainer(
                padding: const EdgeInsets.all(32),
                hasGlow: true,
                glowColor: AppColors.primaryPurple,
                child: const Text(
                  'Which code correctly prints numbers 0 to 4?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Options List
              Expanded(
                child: ListView.builder(
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect = index == _correctIndex;
                    
                    Color borderColor = Colors.white.withValues(alpha: 0.1);
                    Color bgColor = Colors.white.withValues(alpha: 0.05);

                    if (isSelected) {
                      borderColor = AppColors.primaryPurple;
                      bgColor = AppColors.primaryPurple.withValues(alpha: 0.2);
                    }

                    if (_isSubmitted) {
                      if (isCorrect) {
                        borderColor = AppColors.accentGreen;
                        bgColor = AppColors.accentGreen.withValues(alpha: 0.2);
                      } else if (isSelected) {
                        borderColor = AppColors.errorRed;
                        bgColor = AppColors.errorRed.withValues(alpha: 0.2);
                      }
                    }

                    return GestureDetector(
                      onTap: _isSubmitted ? null : () {
                        setState(() {
                          _selectedOptionIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: isSelected && !_isSubmitted
                              ? [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${String.fromCharCode(65 + index)})',
                              style: TextStyle(
                                color: (isSelected || (_isSubmitted && isCorrect)) ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _options[index],
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: (isSelected || (_isSubmitted && isCorrect)) ? Colors.white : AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (_isSubmitted && isCorrect)
                              const Icon(LucideIcons.check, color: AppColors.accentGreen),
                            if (_isSubmitted && isSelected && !isCorrect)
                              const Icon(LucideIcons.x, color: AppColors.errorRed),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Submit Button
              GradientButton(
                text: 'Submit Answer',
                onPressed: _isSubmitted ? () {} : _submitAnswer,
                gradient: (!_isSubmitted && _selectedOptionIndex == null)
                    ? LinearGradient(colors: [Colors.grey.withValues(alpha: 0.5), Colors.grey.withValues(alpha: 0.5)])
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
