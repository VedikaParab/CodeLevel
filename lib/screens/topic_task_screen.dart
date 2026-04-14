import 'package:flutter/material.dart';
import 'concept_visualizer_screen.dart';
import 'topic_notes_screen.dart';
import 'assessment_screen.dart';

class TopicTaskScreen extends StatelessWidget {
  final String topicTitle;
  final String language;
  final String level;
  final String notesContent;
  final String audioUrl;
  final String assessmentContent;
  final String logicContent;
  final String aiFetchedContent;

  const TopicTaskScreen({
    Key? key,
    required this.topicTitle,
    required this.language,
    required this.level,
    required this.notesContent,
    required this.audioUrl,
    required this.assessmentContent,
    required this.logicContent,
    required this.aiFetchedContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topicTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(context, 'Notes (Read + Audio)', Icons.menu_book, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TopicNotesScreen(
                    topicTitle: topicTitle,
                    language: language,
                    level: level,
                    notesContent: notesContent,
                    audioUrl: audioUrl,
                    aiFetchedContent: aiFetchedContent,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildCard(context, 'Assessment', Icons.assignment, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssessmentScreen(
                    language: language,
                    level: level,
                    topic: topicTitle,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildCard(context, 'Logic Building', Icons.extension, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConceptVisualizerScreen(
                    level: level.toLowerCase(),
                    topic: topicTitle.toLowerCase().replaceAll(' ', '_'),
                    subtopics: _deriveSubtopics(topicTitle),
                    language: language.toLowerCase(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAssessmentDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentScreen(
          language: language,
          level: level,
          topic: topicTitle,
        ),
      ),
    );
  }

  List<String> _deriveSubtopics(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('control') || normalized.contains('loop')) {
      return ['for_loop', 'while_loop', 'if_else'];
    }
    if (normalized.contains('function')) {
      return ['function_definition', 'function_call', 'return_statement'];
    }
    if (normalized.contains('recursion')) {
      return ['base_case', 'recursive_call', 'stack_unwind'];
    }
    return [normalized.replaceAll(' ', '_')];
  }
}
