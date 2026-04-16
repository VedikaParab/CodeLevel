import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visualization_content.dart';
import 'package:flutter/foundation.dart';


class VisualizationService {
  static const String _baseUrl =
      'https://n2k1ilptv8.execute-api.ap-south-1.amazonaws.com';

  Future<VisualizationBatchContent> fetchVisualizations({
    required String level,
    required String topic,
    required List<String> subtopics,
    required String language,
    required int graphDepth,
  }) async {
    final uri = Uri.parse('$_baseUrl/generate-visualization');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'level': level,
        'topic': topic,
        'subtopics': subtopics,
        'language': language,
        'graphDepth': graphDepth,
      }),
    );
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Raw body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }

    // Lambda returns { statusCode, headers, body } where body is a JSON string
    final actualData = jsonDecode(response.body) as Map<String, dynamic>;

    final nodes = actualData['nodes'] as List<dynamic>? ?? [];
    final relations = actualData['relations'] as List<dynamic>? ?? [];

    final batchPayload = {
      'level': level,
      'topic': topic,
      'language': language,
      'visualizations': subtopics.map((subtopic) => {
        'subtopic': subtopic,
        'graph': {
          'rootId': nodes.isNotEmpty
              ? (nodes.first as Map<String, dynamic>)['id'].toString()
              : subtopic,
          'metadata': {
            'patternUsed': 'groq',
            'depth': graphDepth,
            'nodeCount': nodes.length,
            'relationCount': relations.length,  // ✅ now accurate
          },
          'nodes': nodes,
          'relations': relations,
        },
      }).toList(),
    };

    return parseVisualizations(
      raw: batchPayload,
      fallbackLevel: level,
      fallbackTopic: topic,
      fallbackLanguage: language,
      fallbackSubtopics: subtopics,
    );
  }

  VisualizationBatchContent parseVisualizations({
    required Map<String, dynamic> raw,
    required String fallbackLevel,
    required String fallbackTopic,
    required String fallbackLanguage,
    required List<String> fallbackSubtopics,
  }) {
    return VisualizationBatchContent.fromRaw(
      raw,
      fallbackLevel: fallbackLevel,
      fallbackTopic: fallbackTopic,
      fallbackLanguage: fallbackLanguage,
      fallbackSubtopics: fallbackSubtopics,
    );
  }
}