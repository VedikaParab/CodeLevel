import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'analytics_screen.dart';

class CourseCompletionScreen extends StatelessWidget {
  const CourseCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Confetti Glow
            Positioned(
              top: -50,
              left: 50,
              right: 50,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)
                  ],
                ),
              ),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Top Trophy Area
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10)
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.trophy, color: AppColors.gold, size: 64),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Main Completion Card
                  GlassContainer(
                    padding: const EdgeInsets.all(32),
                    hasGlow: true,
                    glowColor: AppColors.gold,
                    borderColor: AppColors.gold.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🎉 Python Mastered!',
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.star, color: AppColors.gold, size: 24),
                            Icon(Icons.star, color: AppColors.gold, size: 24),
                            Icon(Icons.star, color: AppColors.gold, size: 24),
                            Icon(Icons.star, color: AppColors.gold, size: 24),
                            Icon(Icons.star_outline, color: AppColors.gold, size: 24),
                            SizedBox(width: 8),
                            Text('4.1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Completed Oct 15, 2026',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            '82% — Advanced Learner',
                            style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Certificate Preview Card
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderColor: AppColors.gold.withValues(alpha: 0.3),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(LucideIcons.award, color: AppColors.gold, size: 32),
                              SizedBox(height: 8),
                              Text('Certificate of Completion', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Alex_Coder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Python Programming', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Download Certificate 📄',
                          onPressed: () {},
                          gradient: AppColors.goldGradient,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  Row(
                    children: [
                      Expanded(child: _buildMiniStatCard('24/24', 'Topics ✓')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMiniStatCard('4,820', 'XP ⭐')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMiniStatCard('18 Days', 'Streak 🔥')),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryPurple),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('View Full Analytics', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Start New Language 🚀',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Compare Languages', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String value, String title) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
