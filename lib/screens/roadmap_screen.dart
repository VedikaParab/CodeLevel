import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../services/ai_roadmap_service.dart';
import '../widgets/level_card.dart';
import 'level_detail_screen.dart';

class RoadmapScreen extends StatefulWidget {
  final String language;

  const RoadmapScreen({super.key, required this.language});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  late final AiRoadmapService _service;
  bool _isLoading = true;
  Map<String, dynamic>? _roadmap;
  String? _error;
  bool _isLoaded = false; // prevents duplicate API calls

  @override
  void initState() {
    super.initState();
    _service = AiRoadmapService();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    if (_isLoaded) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.generateRoadmap(widget.language);
      setState(() {
        _roadmap = data;
        _isLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _navigateToTopic(BuildContext context) {
    // kept for compatibility; not used in new flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: SizedBox.shrink()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.language,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.fileText,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 0.45,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryPurple,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load roadmap',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRoadmap,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final roadmap = _roadmap!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LevelCard(
            title: 'Basic',
            glowColor: Colors.blue,
            onTap: () => _openLevel('basic', roadmap['basic']),
          ),
          LevelCard(
            title: 'Intermediate',
            glowColor: Colors.orange,
            onTap: () => _openLevel('intermediate', roadmap['intermediate']),
          ),
          LevelCard(
            title: 'Advanced',
            glowColor: Colors.purple,
            onTap: () => _openLevel('advanced', roadmap['advanced']),
          ),
        ],
      ),
    );
  }

  void _openLevel(String levelKey, dynamic levelData) {
    final Map<String, dynamic> data = (levelData is Map)
        ? Map<String, dynamic>.from(levelData)
        : <String, dynamic>{};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelDetailScreen(
          levelTitle: levelKey,
          levelData: data,
          language: widget.language,
        ),
      ),
    );
  }

  Widget _buildStartBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryPurple, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Text(
        'START',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
