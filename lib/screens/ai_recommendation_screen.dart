import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'roadmap_tab_screen.dart';

class AiRecommendationScreen extends StatelessWidget {
  final String language;

  const AiRecommendationScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to CodeLevel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Build strong programming skills with a clear, guided learning experience.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildRoadmapCard(context),

            const SizedBox(height: 28),
            const Text(
              'How the App Works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow these steps to move smoothly from foundational concepts to advanced practice.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            _buildGuideStepCard(
              stepLabel: 'Step 1',
              title: 'Choose Your Programming Language',
              description:
                  'Start by selecting the language you want to master. CodeLevel then prepares a personalized roadmap aligned to your learning goals.',
              icon: LucideIcons.languages,
            ),
            const SizedBox(height: 12),
            _buildGuideStepCard(
              stepLabel: 'Step 2',
              title: 'Open Your Personalized Roadmap',
              description:
                  'Your generated plan is available on the roadmap page so you can resume exactly where you left off at any time.',
              icon: LucideIcons.map,
            ),
            const SizedBox(height: 12),
            _buildGuideStepCard(
              stepLabel: 'Step 3',
              title: 'Pick the Right Learning Stage',
              description:
                  'Progress through three structured stages: Basic, Intermediate, and Advanced.',
              icon: LucideIcons.layers,
            ),
            const SizedBox(height: 12),
            _buildGuideStepCard(
              stepLabel: 'Step 4',
              title: 'Complete Topics in Sequence',
              description:
                  'Each stage includes curated topics that build on each other, helping you develop strong conceptual continuity.',
              icon: LucideIcons.listChecks,
            ),
            const SizedBox(height: 12),
            _buildGuideStepCard(
              stepLabel: 'Step 5',
              title: 'Dive Into Subtopics',
              description:
                  'Select any subtopic to open a focused learning view designed to explain concepts with clarity and context.',
              icon: LucideIcons.search,
            ),
            const SizedBox(height: 12),
            _buildGuideStepCard(
              stepLabel: 'Step 6',
              title: 'Learn Through Three Core Modules',
              description:
                  'Every subtopic includes Notes for explanation, Logic Building for practice, and Assessment for quick progress validation.',
              icon: LucideIcons.graduationCap,
            ),
            const SizedBox(height: 16),
            Text(
              'What You Get in Each Subtopic',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildModuleOfferCard(
              title: 'Notes',
              subtitle: 'Build Concept Clarity',
              description:
                  'Concise explanations with structured breakdowns, examples, and key takeaways to help you understand the “why” behind each concept.',
              icon: LucideIcons.fileText,
              accentColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 10),
            _buildModuleOfferCard(
              title: 'Logic Building',
              subtitle: 'Strengthen Problem Solving',
              description:
                  'Interactive exercises that train pattern recognition, algorithmic thinking, and step-by-step reasoning for practical coding challenges.',
              icon: LucideIcons.brainCircuit,
              accentColor: AppColors.primaryPurple,
            ),
            const SizedBox(height: 10),
            _buildModuleOfferCard(
              title: 'Assessment',
              subtitle: 'Measure Learning Progress',
              description:
                  'Focused evaluations to test understanding, identify weak areas, and guide your next learning actions with confidence.',
              icon: LucideIcons.clipboardCheck,
              accentColor: AppColors.accentGreen,
            ),
            const SizedBox(height: 28),

            _buildFutureOfCodeLevelSection(),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RoadmapTabScreen(language: language),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.map,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Learning Roadmap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Continue your structured learning journey',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideStepCard({
    required String stepLabel,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepLabel,
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleOfferCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureOfCodeLevelSection() {
    final features = [
      const _FutureFeature(
        title: 'Integrated Code Editor',
        description:
            'Write and test code without leaving the learning environment. Our upcoming integrated code editor will let you practice instantly, experiment with different approaches, and strengthen your coding skills directly inside the platform.',
        icon: LucideIcons.code,
      ),
      const _FutureFeature(
        title: 'Concept Simulators',
        description:
            'Understanding programming becomes easier when you can see it in action. Interactive simulators will visually demonstrate how algorithms and programming concepts work step-by-step, helping you grasp complex logic much faster.',
        icon: LucideIcons.puzzle,
      ),
      const _FutureFeature(
        title: 'AI Learning Assistant',
        description:
            'Stuck on a concept? Our AI assistant will guide you with explanations, hints, and simplified breakdowns so you can overcome challenges and keep progressing in your learning journey.',
        icon: LucideIcons.bot,
      ),
      const _FutureFeature(
        title: 'Real-World Coding Challenges',
        description:
            'Move beyond theory and practice with real-world coding problems. These challenges will help you apply what you learn, strengthen your logic, and build the problem-solving mindset used by professional developers.',
        icon: LucideIcons.listChecks,
      ),
      const _FutureFeature(
        title: 'Progress Insights & Learning Analytics',
        description:
            'Track your growth with detailed learning insights. You will be able to monitor completed topics, measure improvement, and stay motivated as you move closer to mastering your chosen programming language.',
        icon: LucideIcons.barChart2,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The Future of CodeLevel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are continuously building tools that make learning programming more interactive, practical, and powerful.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.sparkles, color: AppColors.primaryPurple, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CodeLevel is evolving into a complete interactive programming learning platform.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 700 ? 3 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 3 ? 0.92 : 0.82,
                ),
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return _FutureFeatureCard(feature: feature);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FutureFeature {
  final String title;
  final String description;
  final IconData icon;

  const _FutureFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _FutureFeatureCard extends StatefulWidget {
  final _FutureFeature feature;

  const _FutureFeatureCard({required this.feature});

  @override
  State<_FutureFeatureCard> createState() => _FutureFeatureCardState();
}

class _FutureFeatureCardState extends State<_FutureFeatureCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.985
        : _isHovered
            ? 1.01
            : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapCancel: () => setState(() => _isPressed = false),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTap: () {},
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.feature.icon,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.feature.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      widget.feature.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
