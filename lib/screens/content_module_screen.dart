import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';

class ContentModuleScreen extends StatefulWidget {
  const ContentModuleScreen({super.key});

  @override
  State<ContentModuleScreen> createState() => _ContentModuleScreenState();
}

class _ContentModuleScreenState extends State<ContentModuleScreen> {
  final List<String> _tabs = ['Theory', 'Syntax', 'Examples', 'Visual', 'Mistakes', 'Summary'];
  String _activeTab = 'Theory';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Text('3 of 7 sections', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Strip
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isActive = tab == _activeTab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? AppColors.primaryPurple : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What is a For Loop?',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.6),
                      children: const [
                        TextSpan(text: 'A '),
                        TextSpan(text: 'for loop', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' is used for iterating over a '),
                        TextSpan(text: 'sequence', style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' (that is either a list, a tuple, a dictionary, a set, or a string).'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Pro Tip Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withValues(alpha: 0.05),
                      border: const Border(left: BorderSide(color: Colors.yellow, width: 4)),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.lightbulb, color: Colors.yellow, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.yellow, fontSize: 14),
                              children: [
                                TextSpan(text: 'Pro Tip: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: 'Use range() for number sequences.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Syntax Card
                  const Text('Syntax', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.5),
                        children: [
                          TextSpan(text: 'for ', style: TextStyle(color: AppColors.primaryPurple)),
                          TextSpan(text: 'variable ', style: TextStyle(color: Colors.cyan)),
                          TextSpan(text: 'in ', style: TextStyle(color: AppColors.primaryPurple)),
                          TextSpan(text: 'sequence:\n', style: TextStyle(color: Colors.cyan)),
                          TextSpan(text: '    statement', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Example Card
                  const Text('Live Example', style: TextStyle(color: AppColors.primaryPurple, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GlassContainer(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.5),
                              children: [
                                TextSpan(text: 'for ', style: TextStyle(color: AppColors.primaryPurple)),
                                TextSpan(text: 'i ', style: TextStyle(color: Colors.cyan)),
                                TextSpan(text: 'in ', style: TextStyle(color: AppColors.primaryPurple)),
                                TextSpan(text: 'range(3):\n', style: TextStyle(color: AppColors.accentGreen)),
                                TextSpan(text: '    print(i)', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '0\n1\n2',
                                style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.accentGreen, width: 1),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(LucideIcons.play, color: AppColors.accentGreen, size: 14),
                                    SizedBox(width: 4),
                                    Text('Run', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Previous', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: 'Next',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          
          // Progress Dots
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                final isActive = index == 2;
                final isPassed = index < 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryPurple : (isPassed ? AppColors.primaryPurple.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
