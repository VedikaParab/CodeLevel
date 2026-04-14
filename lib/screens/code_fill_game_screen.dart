import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';

class CodeFillGameScreen extends StatefulWidget {
  const CodeFillGameScreen({super.key});

  @override
  State<CodeFillGameScreen> createState() => _CodeFillGameScreenState();
}

class _CodeFillGameScreenState extends State<CodeFillGameScreen> {
  String? _selectedOption;
  bool _submitted = false;

  final List<String> _options = ['range', 'list', 'len', 'int'];

  void _submit() {
    if (_selectedOption != null) {
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Level 7 / 20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textSecondary)),
        centerTitle: true,
        actions: [
          Row(
            children: const [
              Icon(LucideIcons.heart, color: AppColors.errorRed, size: 20),
              SizedBox(width: 4),
              Icon(LucideIcons.heart, color: AppColors.errorRed, size: 20),
              SizedBox(width: 4),
              Icon(LucideIcons.heart, color: AppColors.errorRed, size: 20),
              SizedBox(width: 16),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 0.35,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.errorRed),
                    ),
                    child: const Text(
                      'COMPULSORY',
                      style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.7,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      const Text('14', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      hasGlow: true,
                      glowColor: AppColors.primaryPurple,
                      borderColor: AppColors.primaryPurple,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Fill in the blank to print numbers 0 to 4',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Code Block with Blank
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 20, height: 1.8),
                                children: [
                                  const TextSpan(text: 'for ', style: TextStyle(color: AppColors.primaryPurple)),
                                  const TextSpan(text: 'i ', style: TextStyle(color: Colors.cyan)),
                                  const TextSpan(text: 'in '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: _selectedOption != null ? (_submitted && _selectedOption == 'range' ? AppColors.accentGreen.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1)) : Colors.white.withValues(alpha: 0.05),
                                        border: Border.all(
                                          color: _selectedOption != null ? (_submitted && _selectedOption == 'range' ? AppColors.accentGreen : AppColors.primaryPurple) : Colors.white.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _selectedOption ?? '_____',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 20,
                                          color: _selectedOption != null ? (_submitted && _selectedOption == 'range' ? AppColors.accentGreen : Colors.white) : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: '(5):\n'),
                                  const TextSpan(text: '    print(i)', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Options Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isSelected = _selectedOption == option;
                        Color borderColor = Colors.white.withValues(alpha: 0.1);
                        Color bgColor = Colors.white.withValues(alpha: 0.05);

                        if (isSelected) {
                          borderColor = AppColors.primaryPurple;
                          bgColor = AppColors.primaryPurple.withValues(alpha: 0.2);
                        }

                        if (_submitted) {
                          if (option == 'range') {
                            borderColor = AppColors.accentGreen;
                            bgColor = AppColors.accentGreen.withValues(alpha: 0.2);
                          } else if (isSelected && option != 'range') {
                            borderColor = AppColors.errorRed;
                            bgColor = AppColors.errorRed.withValues(alpha: 0.2);
                          }
                        }

                        return GestureDetector(
                          onTap: _submitted ? null : () {
                            setState(() {
                              _selectedOption = option;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: isSelected && !_submitted
                                  ? [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            if (_submitted && _selectedOption == 'range') ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🎉 Correct! ', style: TextStyle(color: AppColors.accentGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('+50 XP', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GradientButton(
                text: _submitted ? 'Next Level →' : 'Submit',
                onPressed: _submitted ? () {} : _submit,
                gradient: (!_submitted && _selectedOption == null) 
                    ? LinearGradient(colors: [Colors.grey.withValues(alpha: 0.5), Colors.grey.withValues(alpha: 0.5)])
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
