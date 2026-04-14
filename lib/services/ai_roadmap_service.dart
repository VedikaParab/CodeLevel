import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String BASE_URL =
  'https://sihq28poz9.execute-api.ap-south-1.amazonaws.com';

/// Clean, testable service for requesting AI-generated roadmaps.
///
/// This class follows simple clean-architecture principles: it is a
/// single-responsibility, easily-mockable service that performs HTTP
/// requests and returns parsed domain JSON.
class AiRoadmapService {
  final http.Client _client;

  AiRoadmapService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends a POST to `BASE_URL/generate-roadmap` with body `{ "language": language }`.
  /// Returns decoded JSON as a `Map<String, dynamic>` on success.
  /// Throws an [Exception] with a descriptive message on failure.
  Future<Map<String, dynamic>> generateRoadmap(String language) async {
    final uri = Uri.parse('$BASE_URL/generate-roadmap');
    final body = jsonEncode({'language': language});
    try {
      // Debug: log outgoing request body to aid diagnosing server JSON errors
      // Remove or guard this in production.
      // ignore: avoid_print
      print('AiRoadmapService POST $uri -> $body');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
            'Request failed (${response.statusCode}): ${response.body}');
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw Exception('Invalid response format');
      } on FormatException catch (e) {
        // Include server response body to help debugging invalid JSON payloads
        throw Exception('Invalid JSON format: ${e.message} - payload: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format');
    }
  }

  /// Dispose underlying resources.
  void dispose() => _client.close();
}
