import 'package:flutter/material.dart';

import '../models/visualization_content.dart';
import '../services/visualization_service.dart';
import '../theme/app_colors.dart';
import '../widgets/concept_graph_view.dart';
import '../widgets/glass_container.dart';

class ConceptVisualizerScreen extends StatefulWidget {
  final String level;
  final String topic;
  final List<String> subtopics;
  final String language;
  final Map<String, dynamic>? visualizationPayload;

  const ConceptVisualizerScreen({
    super.key,
    required this.level,
    required this.topic,
    required this.subtopics,
    required this.language,
    this.visualizationPayload,
  });

  @override
  State<ConceptVisualizerScreen> createState() =>
      _ConceptVisualizerScreenState();
}

class _ConceptVisualizerScreenState extends State<ConceptVisualizerScreen> {
  final VisualizationService _visualizationService = VisualizationService();

  late VisualizationBatchContent _batch;
  bool _isFetching = false;
  String? _fetchError;

  @override
  void initState() {
    super.initState();

    _batch = _visualizationService.parseVisualizations(
      raw: _buildFallbackBatchPayload(),
      fallbackLevel: widget.level,
      fallbackTopic: widget.topic,
      fallbackLanguage: widget.language,
      fallbackSubtopics: widget.subtopics,
    );

    if (widget.visualizationPayload != null) {
      _batch = _visualizationService.parseVisualizations(
        raw: widget.visualizationPayload!,
        fallbackLevel: widget.level,
        fallbackTopic: widget.topic,
        fallbackLanguage: widget.language,
        fallbackSubtopics: widget.subtopics,
      );
      return;
    }

    _loadVisualizationFromApi();
  }

  Future<void> _loadVisualizationFromApi() async {
    setState(() {
      _isFetching = true;
      _fetchError = null;
    });

    try {
      final batch = await _visualizationService.fetchVisualizations(
        level: widget.level.toLowerCase(),
        topic: widget.topic,
        subtopics: widget.subtopics,
        language: widget.language,
        graphDepth: _requiredGraphDepth(widget.level),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _batch = batch;
        _isFetching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isFetching = false;
        _fetchError =
            'Using fallback graph for now. Live graph will come from /generate-visualization.';
      });
    }
  }

  int _requiredGraphDepth(String level) {
    final normalized = level.toLowerCase();
    if (normalized == 'basic') {
      return 7;
    }
    return 11;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Concept Visualizer')),
      body: Column(
        children: [
          if (_isFetching) const LinearProgressIndicator(minHeight: 2),
          if (_fetchError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                _fetchError!,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTopSummary(),
                const SizedBox(height: 12),
                ..._batch.visualizations.map(_buildSubtopicGraphCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummary() {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Level: ${_batch.level}  |  Topic: ${_batch.topic}  |  ${_batch.visualizations.length} subtopics',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubtopicGraphCard(SubtopicVisualizationContent item) {
    final graph = item.content.graph;
    final metadata = graph.metadata;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.primaryBlue.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subtopic.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('pattern: ${metadata.patternUsed}'),
                _buildChip('depth: ${metadata.depth}'),
                _buildChip('nodes: ${metadata.nodeCount}'),
                _buildChip('relations: ${metadata.relationCount}'),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(height: 430, child: ConceptGraphView(graph: graph)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Map<String, dynamic> _buildFallbackBatchPayload() {
    return {
      'level': widget.level,
      'topic': widget.topic,
      'language': widget.language,
      'visualizations': widget.subtopics
          .map(
            (subtopic) => {
              'subtopic': subtopic,
              'graph': {
                'rootId': subtopic,
                'metadata': {
                  'patternUsed': 'fallback',
                  'depth': 1,
                  'nodeCount': 1,
                  'relationCount': 0,
                },
                'nodes': [
                  {
                    'id': subtopic,
                    'label': subtopic.replaceAll('_', ' '),
                    'type': 'concept',
                    'description': 'Concept node',
                    'level': 1,
                    'expandable': false,
                    'cognitive': 'understand',
                  },
                ],
                'relations': [],
              },
            },
          )
          .toList(),
    };
  }
}
