import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  // Using the latest key provided by you
  static const String _apiKey = 'AIzaSyBQ3OPL9S97IUfSMnH4KMiwTmqRfSJHpOU';
  
  // As requested: Use ONLY this model
  static const String _modelName = 'gemini-2.5-flash';

  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(model: _modelName, apiKey: _apiKey);

  Future<String> getHint({
    required String language,
    required String currentCode,
    required String levelDescription,
  }) async {
    if (_apiKey.isEmpty || _apiKey.contains('REPLACE_WITH')) {
      return "AI Hint: Please configure your Gemini API Key.";
    }

    final prompt = """
You are an expert coding tutor for a game called 'CodeLevel'.
The user is learning $language.
The current level objective is: $levelDescription
The user's current code is:
```$language
$currentCode
```

Provide a short, encouraging hint (maximum 3 sentences) to help them progress without giving away the full solution.
""";

    try {
      return await _tryGenerateContent(prompt);
    } catch (e) {
      final errorStr = e.toString();
      debugPrint("Gemini Error: $errorStr");

      // Rate limit (429) -> Wait and retry once
      if (errorStr.contains('429')) {
        debugPrint("Rate limit hit. Waiting 5 seconds...");
        await Future.delayed(const Duration(seconds: 5));
        try {
          return await _tryGenerateContent(prompt);
        } catch (retryError) {
          return "AI is busy (Rate Limit). Please try again in a minute!";
        }
      }

      // Model not found (404)
      if (errorStr.contains('404')) {
        return "AI Error: Model not available. Please confirm the model name in Google AI Studio.";
      }

      // Quota exceeded (403/Forbidden often used for quota outside of 429)
      if (errorStr.contains('403')) {
        return "Daily AI quota reached. See you tomorrow for more hints!";
      }

      return "AI Error: Something went wrong. (" + errorStr + ")";
    }
  }

  Future<String> _tryGenerateContent(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "I'm thinking... but I couldn't find the right words!";
  }
}
