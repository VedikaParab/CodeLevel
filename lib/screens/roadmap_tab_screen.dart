import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/level_card.dart';
import '../services/roadmap_service.dart';
import 'level_detail_screen.dart';

class RoadmapTabScreen extends StatefulWidget {
  final String language;

  const RoadmapTabScreen({super.key, required this.language});

  @override
  State<RoadmapTabScreen> createState() => _RoadmapTabScreenState();
}

class _RoadmapTabScreenState extends State<RoadmapTabScreen> {
  final RoadmapService _service = RoadmapService();
  bool _isLoading = false;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _onLevelTap(String levelKey) async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> result = await _service.generateRoadmap(
        widget.language,
        levelKey,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate and pass the returned JSON to the detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LevelDetailScreen(
            levelTitle: levelKey,
            levelData: result,
            language: widget.language,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Roadmap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LevelCard(
                    title: 'Basic',
                    glowColor: Colors.blue,
                    onTap: () => _onLevelTap('basic'),
                  ),
                  LevelCard(
                    title: 'Intermediate',
                    glowColor: Colors.orange,
                    onTap: () => _onLevelTap('intermediate'),
                  ),
                  LevelCard(
                    title: 'Advanced',
                    glowColor: Colors.purple,
                    onTap: () => _onLevelTap('advanced'),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
