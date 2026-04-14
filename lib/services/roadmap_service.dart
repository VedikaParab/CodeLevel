import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class RoadmapService {
  final http.Client _client;

  RoadmapService({http.Client? client}) : _client = client ?? http.Client();

  static const String _endpoint = 'https://sihq28poz9.execute-api.ap-south-1.amazonaws.com/generate-roadmap';

  /// Sends POST { "language": language, "level": level }
  /// Returns decoded JSON as Map<String, dynamic>.
  /// Throws an Exception on network/format errors.
  Future<Map<String, dynamic>> generateRoadmap(String language, String level) async {
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({'language': language, 'level': level});

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Request failed (${response.statusCode}): ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;

      throw Exception('Invalid response format: expected JSON object');
    } on TimeoutException {
      throw Exception('Request timed out after 20 seconds');
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Close the underlying HTTP client when done.
  void dispose() => _client.close();
}
