import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://sihq28poz9.execute-api.ap-south-1.amazonaws.com";

  static Future<Map<String, dynamic>> generateRoadmap(String language) async {
    final url = Uri.parse("$baseUrl/generate-roadmap");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"language": language}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load roadmap");
    }
  }

  static Future<Map<String, dynamic>> generateVisualization({
    required String level,
    required String topic,
    required List<String> subtopics,
    required String language,
    String taskType = 'logic_building',
    int graphDepth = 5,
  }) async {
    final url = Uri.parse("$baseUrl/generate-visualization");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "level": level,
        "topic": topic,
        "subtopics": subtopics,
        "language": language,
        "taskType": taskType,
        "graphDepth": graphDepth,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load visualization (${response.statusCode}): ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final body = decoded['body'];
      if (body is String) {
        final parsedBody = jsonDecode(body);
        if (parsedBody is Map<String, dynamic>) {
          return parsedBody;
        }
      }
      return decoded;
    }

    throw Exception('Invalid visualization response format');
  }
}
