class ConceptGraphNode {
  final String id;
  final String label;
  final String type;
  final String description;
  final int level;
  final bool expandable;
  final String cognitive;

  const ConceptGraphNode({
    required this.id,
    required this.label,
    required this.type,
    required this.description,
    required this.level,
    required this.expandable,
    required this.cognitive,
  });

  factory ConceptGraphNode.fromRaw(Map<String, dynamic> raw) {
    return ConceptGraphNode(
      id: (raw['id'] ?? '').toString(),
      label: (raw['label'] ?? '').toString(),
      type: (raw['type'] ?? 'concept').toString(),
      description: (raw['description'] ?? '').toString(),
      level: (raw['level'] is int)
          ? raw['level'] as int
          : int.tryParse('${raw['level'] ?? 1}') ?? 1,
      expandable: raw['expandable'] == true,
      cognitive: (raw['cognitive'] ?? 'understand').toString(),
    );
  }
}

class ConceptGraphRelation {
  final String from;
  final String to;
  final String type;
  final String label;

  const ConceptGraphRelation({
    required this.from,
    required this.to,
    required this.type,
    required this.label,
  });

  factory ConceptGraphRelation.fromRaw(Map<String, dynamic> raw) {
    final type = (raw['type'] ?? 'hierarchy').toString();
    final label = (raw['label'] ?? '').toString();

    return ConceptGraphRelation(
      from: (raw['from'] ?? '').toString(),
      to: (raw['to'] ?? '').toString(),
      type: type,
      label: label.isEmpty ? type : label,
    );
  }
}

class ConceptGraphMetadata {
  final String patternUsed;
  final int depth;
  final int nodeCount;
  final int relationCount;

  const ConceptGraphMetadata({
    required this.patternUsed,
    required this.depth,
    required this.nodeCount,
    required this.relationCount,
  });

  factory ConceptGraphMetadata.fromRaw(Map<String, dynamic> raw) {
    int _toInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      return int.tryParse('${value ?? fallback}') ?? fallback;
    }

    return ConceptGraphMetadata(
      patternUsed: (raw['patternUsed'] ?? 'unknown').toString(),
      depth: _toInt(raw['depth'], 1),
      nodeCount: _toInt(raw['nodeCount'], 0),
      relationCount: _toInt(raw['relationCount'], 0),
    );
  }
}

class ConceptGraph {
  final String rootId;
  final ConceptGraphMetadata metadata;
  final List<ConceptGraphNode> nodes;
  final List<ConceptGraphRelation> relations;

  const ConceptGraph({
    required this.rootId,
    required this.metadata,
    required this.nodes,
    required this.relations,
  });

  factory ConceptGraph.fromRaw(
    Map<String, dynamic> raw, {
    required String fallbackSubtopic,
  }) {
    final nodes = (raw['nodes'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(ConceptGraphNode.fromRaw)
        .where((node) => node.id.isNotEmpty)
        .toList();

    final relations = (raw['relations'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(ConceptGraphRelation.fromRaw)
        .where((relation) => relation.from.isNotEmpty && relation.to.isNotEmpty)
        .toList();

    final fallbackRootId = fallbackSubtopic.toLowerCase().replaceAll(' ', '_');
    final rootId = (raw['rootId'] ?? fallbackRootId).toString();

    final safeNodes = nodes.isEmpty
        ? [
            ConceptGraphNode(
              id: fallbackRootId,
              label: fallbackSubtopic.replaceAll('_', ' '),
              type: 'concept',
              description: 'Concept overview for $fallbackSubtopic',
              level: 1,
              expandable: false,
              cognitive: 'understand',
            ),
          ]
        : nodes;

    final safeRootId = safeNodes.any((node) => node.id == rootId)
        ? rootId
        : safeNodes.first.id;

    final metadataRaw = raw['metadata'];
    final metadata = metadataRaw is Map<String, dynamic>
        ? ConceptGraphMetadata.fromRaw(metadataRaw)
        : ConceptGraphMetadata(
            patternUsed: 'fallback',
            depth: safeNodes
                .map((node) => node.level)
                .fold(1, (a, b) => a > b ? a : b),
            nodeCount: safeNodes.length,
            relationCount: relations.length,
          );

    return ConceptGraph(
      rootId: safeRootId,
      metadata: metadata,
      nodes: safeNodes,
      relations: relations,
    );
  }
}

class SubtopicVisualizationContent {
  final String subtopic;
  final VisualizationContent content;

  const SubtopicVisualizationContent({
    required this.subtopic,
    required this.content,
  });
}

class VisualizationBatchContent {
  final String level;
  final String topic;
  final String language;
  final List<SubtopicVisualizationContent> visualizations;

  const VisualizationBatchContent({
    required this.level,
    required this.topic,
    required this.language,
    required this.visualizations,
  });

  factory VisualizationBatchContent.fromRaw(
    Map<String, dynamic> raw, {
    required String fallbackLevel,
    required String fallbackTopic,
    required String fallbackLanguage,
    required List<String> fallbackSubtopics,
  }) {
    final level = (raw['level'] ?? fallbackLevel).toString();
    final topic = (raw['topic'] ?? fallbackTopic).toString();
    final language = (raw['language'] ?? fallbackLanguage).toString();

    final rawVisualizations =
        (raw['visualizations'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();

    final parsedVisualizations = rawVisualizations.map((item) {
      final subtopic = (item['subtopic'] ?? 'subtopic').toString();
      return SubtopicVisualizationContent(
        subtopic: subtopic,
        content: VisualizationContent.fromRaw(item, fallbackConcept: subtopic),
      );
    }).toList();

    final safeVisualizations = parsedVisualizations.isEmpty
        ? fallbackSubtopics
              .map(
                (subtopic) => SubtopicVisualizationContent(
                  subtopic: subtopic,
                  content: VisualizationContent.fromRaw(
                    const {},
                    fallbackConcept: subtopic,
                  ),
                ),
              )
              .toList()
        : parsedVisualizations;

    return VisualizationBatchContent(
      level: level,
      topic: topic,
      language: language,
      visualizations: safeVisualizations,
    );
  }
}

class VisualizationContent {
  final ConceptGraph graph;

  const VisualizationContent({required this.graph});

  factory VisualizationContent.fromRaw(
    Map<String, dynamic> raw, {
    required String fallbackConcept,
  }) {
    final rawGraph = raw['graph'];
    final graph = rawGraph is Map<String, dynamic>
        ? ConceptGraph.fromRaw(rawGraph, fallbackSubtopic: fallbackConcept)
        : ConceptGraph.fromRaw(const {}, fallbackSubtopic: fallbackConcept);

    return VisualizationContent(graph: graph);
  }
}
