import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class Level {
  final String id;
  final String title;
  final String description;
  final String language; // python, javascript, sql, java
  final String initialCode;
  final Map<String, dynamic> initialGameState;
  final List<String> solution;

  Level({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.initialCode,
    required this.initialGameState,
    this.solution = const [],
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] != null ? json['id'].toString() : "0",
      title: json['title'] != null ? json['title'].toString() : "Untitled Level",
      description: json['description'] != null ? json['description'].toString() : "No description provided.",
      language: json['language'] != null ? json['language'].toString() : "python",
      initialCode: json['initialCode'] != null ? json['initialCode'].toString() : "",
      initialGameState: json['initialGameState'] is Map ? Map<String, dynamic>.from(json['initialGameState']) : {},
      solution: json['solution'] is List ? List<String>.from(json['solution']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'initialCode': initialCode,
      'initialGameState': initialGameState,
      'solution': solution,
    };
  }
}

class LevelLoader {
  static Future<Level> loadLevel(String language, String levelId) async {
    // Explicit concatenation to avoid any string interpolation bugs
    final String path = "assets/levels/$language/$levelId.json";
    
    try {
      debugPrint("FETCHING ASSET: $path");
      final jsonString = await rootBundle.loadString(path);
      final dynamic jsonMap = json.decode(jsonString);
      
      debugPrint("LOAD SUCCESS: $path");
      return Level.fromJson(jsonMap);
    } catch (e) {
      debugPrint("LOAD FAILED: $path - Error: $e");
      
      // Fallback with zero interpolation
      return Level(
        id: levelId,
        title: "Default Level ($levelId)",
        description: "Complete the challenges to advance!",
        language: language,
        initialCode: "# Start coding here",
        initialGameState: {},
      );
    }
  }
}
