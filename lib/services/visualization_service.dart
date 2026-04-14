import '../models/visualization_content.dart';
import 'api_service.dart';

class VisualizationService {
  Future<VisualizationBatchContent> fetchVisualizations({
    required String level,
    required String topic,
    required List<String> subtopics,
    required String language,
    int graphDepth = 5,
  }) async {
    final raw = await ApiService.generateVisualization(
      level: level,
      topic: topic,
      subtopics: subtopics,
      language: language,
      graphDepth: graphDepth,
    );

    return VisualizationBatchContent.fromRaw(
      raw,
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
