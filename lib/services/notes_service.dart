import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NotesService {
  final http.Client _client;

  NotesService({http.Client? client}) : _client = client ?? http.Client();

  static const String _endpoint = 'https://sihq28poz9.execute-api.ap-south-1.amazonaws.com/notes';

  Future<Map<String, dynamic>> generateNotes({
    required String language,
    required String level,
    required String topic,
  }) async {
    final uri = Uri.parse(_endpoint);
    final payload = jsonEncode({
      'language': language,
      'level': level,
      'topic': topic,
    });

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception(
          'Notes request failed (${response.statusCode}): ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('body') && decoded['body'] is String) {
          final nested = jsonDecode(decoded['body'] as String);
          if (nested is Map<String, dynamic>) {
            return nested;
          }
        }
        return decoded;
      }

      throw Exception('Invalid notes response format');
    } on TimeoutException {
      throw Exception('Notes request timed out');
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid notes JSON: ${e.message}');
    }
  }

  void dispose() => _client.close();
}
