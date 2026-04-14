import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'topic_task_screen.dart';

/// LevelDetailScreen
///
/// Displays an overview, expandable topics, conceptual map cards and a
/// logical timeline. Receives `levelData` (Map<String, dynamic>) and
/// renders the content with full null-safety. Dark theme styling is used.
class LevelDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? levelData;
  final String? levelTitle;
  final String? language;

  const LevelDetailScreen({
    super.key,
    this.levelData,
    this.levelTitle,
    this.language,
  });

  List<dynamic> _safeList(dynamic v) => (v is List) ? v : <dynamic>[];

  Widget _overviewSection(String overview) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Text(
                overview,
                style: const TextStyle(color: Colors.white, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicsSection(BuildContext context, List<dynamic> topics) {
    if (topics.isEmpty) {
      return GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: const Text(
          'No topics available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topics.map<Widget>((t) {
        final topic = (t is Map) ? t : <String, dynamic>{};
        final title = (topic['title'] ?? '').toString();
        final theory = (topic['theory'] ?? '').toString();
        final keyPoints = _safeList(
          topic['key_points'],
        ).map((e) => e.toString()).toList();
        final mistakes = _safeList(
          topic['common_mistakes'],
        ).map((e) => e.toString()).toList();

        final aiSections = <String>[];
        if (theory.isNotEmpty) {
          aiSections.add(theory);
        }
        if (keyPoints.isNotEmpty) {
          aiSections.add('Key points\n• ${keyPoints.join('\n• ')}');
        }
        if (mistakes.isNotEmpty) {
          aiSections.add('Common mistakes\n• ${mistakes.join('\n• ')}');
        }
        final aiFetchedContent = aiSections.join('\n\n');

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicTaskScreen(
                      topicTitle: title.isEmpty ? 'Topic' : title,
                      language: (language == null || language!.isEmpty)
                          ? 'Python'
                          : language!,
                      level: (levelTitle == null || levelTitle!.isEmpty)
                          ? 'basic'
                          : levelTitle!,
                      notesContent: theory.isEmpty
                          ? 'No notes available.'
                          : theory,
                      audioUrl: '',
                      assessmentContent:
                          'Assessment module for ${title.isEmpty ? 'this topic' : title}.',
                      logicContent:
                          'Logic building module for ${title.isEmpty ? 'this topic' : title}.',
                      aiFetchedContent: aiFetchedContent.isEmpty
                          ? 'No AI content available.'
                          : aiFetchedContent,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _conceptualSection(List<dynamic> concepts) {
    if (concepts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: concepts.map<Widget>((c) {
        final m = (c is Map) ? c : <String, dynamic>{};
        final concept = (m['concept'] ?? '').toString();
        final definition = (m['definition'] ?? '').toString();
        final why = (m['why_important'] ?? '').toString();
        final connected = _safeList(
          m['connected_to'],
        ).map((e) => e.toString()).toList();

        return GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concept,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (definition.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    definition,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              if (why.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    'Why: $why',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              if (connected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    'Connected to: ${connected.join(', ')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _logicalSection(List<dynamic> steps) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map<Widget>((entry) {
        final idx = entry.key;
        final s = entry.value is Map
            ? entry.value as Map<String, dynamic>
            : <String, dynamic>{};
        final stepNum = (s['step'] ?? (idx + 1)).toString();
        final learn = (s['learn'] ?? '').toString();
        final reason = (s['reason'] ?? '').toString();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryPurple,
                child: Text(
                  stepNum,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (learn.isNotEmpty)
                      Text(learn, style: const TextStyle(color: Colors.white)),
                    if (reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Why: $reason',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = levelData ?? <String, dynamic>{};

    final overview = (data['overview'] ?? data['content'] ?? '').toString();
    final topics = _safeList(data['topics']);
    final conceptual = _safeList(data['conceptual_map']);
    final logical = _safeList(data['logical_map']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text((levelTitle ?? 'Level').toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _overviewSection(overview),
              const SizedBox(height: 12),
              Text(
                'Topics',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _topicsSection(context, topics),
              const SizedBox(height: 12),
              Text(
                'Conceptual Map',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _conceptualSection(conceptual),
              const SizedBox(height: 12),
              Text(
                'Logical Map',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _logicalSection(logical),
            ],
          ),
        ),
      ),
    );
  }
}
