import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'main_navigation_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Python', 'icon': 'py', 'difficulty': 'Beginner', 'color': Colors.blue, 'popular': true},
    {'name': 'JavaScript', 'icon': 'js', 'difficulty': 'Beginner', 'color': Colors.yellow, 'popular': true},
    {'name': 'Java', 'icon': 'java', 'difficulty': 'Intermediate', 'color': Colors.orange, 'popular': false},
    {'name': 'C++', 'icon': 'cpp', 'difficulty': 'Advanced', 'color': Colors.blueAccent, 'popular': false},
    {'name': 'Go', 'icon': 'go', 'difficulty': 'Intermediate', 'color': Colors.cyan, 'popular': false},
    {'name': 'Rust', 'icon': 'rust', 'difficulty': 'Advanced', 'color': Colors.deepOrange, 'popular': false},
    {'name': 'TypeScript', 'icon': 'ts', 'difficulty': 'Intermediate', 'color': Colors.blueAccent, 'popular': false},
    {'name': 'Swift', 'icon': 'swift', 'difficulty': 'Beginner', 'color': Colors.orangeAccent, 'popular': false},
  ];

  void _handleGenerate() {
    if (_selectedLanguage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen(initialLanguage: _selectedLanguage!)),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
              child: Column(
                children: [
                  Text(
                    'Choose Your Language',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI will build your personalized roadmap',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(LucideIcons.search, color: AppColors.textSecondary, size: 20),
                        hintText: 'Search language...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid Section
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = _selectedLanguage == lang['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['name'];
                      });
                    },
                    child: GlassContainer(
                      hasGlow: isSelected,
                      borderColor: isSelected ? AppColors.primaryPurple : null,
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Language Icon Placeholder (using colored circles for now)
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: (lang['color'] as Color).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: lang['color'], width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    lang['icon'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: lang['color'],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Text(
                                lang['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Difficulty Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lang['difficulty'],
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Popular Tag
                          if (lang['popular'])
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                          // Checkmark Badge
                          if (isSelected)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(LucideIcons.check, color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GradientButton(
                text: 'Generate My Roadmap',
                onPressed: _selectedLanguage != null ? _handleGenerate : () {},
                gradient: _selectedLanguage != null
                    ? AppColors.primaryGradient
                    : LinearGradient(colors: [Colors.grey.withValues(alpha: 0.2), Colors.grey.withValues(alpha: 0.2)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
