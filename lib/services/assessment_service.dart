import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/assessment_question.dart';

class AssessmentService {
  static const String _endpoint =
      'https://whec0x2e0g.execute-api.ap-south-1.amazonaws.com/generate-assessment';

  final http.Client _client;

  AssessmentService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<AssessmentQuestion>> fetchQuestions({
    required String language,
    required String level,
    required String topic,
  }) async {
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({
      'language': language,
      'level': level,
      'topic': topic,
    });

    try {
      final resp = await _client
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      if (data == null || data['questions'] == null) {
        throw Exception('Invalid response format');
      }

      final list = data['questions'] as List;
      return list
          .map((e) => AssessmentQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException catch (_) {
      throw Exception('Request timed out');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }
}
