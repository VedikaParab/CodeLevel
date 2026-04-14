import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../games/python/python_game.dart';
import '../games/javascript/js_logic_game.dart';
import '../games/sql/sql_puzzle_game.dart';
import '../games/java/java_oop_game.dart';
import '../../shared/editor/code_editor.dart';
import '../../shared/level_system/level_loader.dart';
import '../../services/gemini_service.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  String? selectedGame;
  String currentCode = '';
  Level? currentLevel;
  int currentLevelIndex = 1;
  bool isLoadingHint = false;
  String? aiHint;
  
  final GeminiService gemini = GeminiService();

  // Cache for game instances/engines
  PythonGame? pythonGame;
  PythonGameEngine? pythonEngine;
  JavaGameEngine? javaEngine;
  JSLogicGameEngine? jsEngine;
  SQlGameEngine? sqlEngine;

  void _selectGame(String game) async {
    final level = await LevelLoader.loadLevel(game, 'level_1');
    setState(() {
      selectedGame = game;
      currentLevel = level;
      currentLevelIndex = 1;
      currentCode = level.initialCode;
      aiHint = null;
      
      if (game == 'python') {
        pythonGame = PythonGame();
        pythonEngine = PythonGameEngine(
          pythonGame!,
          onGameWon: _onGameWon,
          onGameLost: _onGameLost,
        );
        pythonEngine!.currentLevel = level;
        
        // Add feedback listener
        pythonEngine!.onStepResult = (index, isCorrect, message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(isCorrect ? Icons.check_circle : Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(isCorrect ? "Step ${index + 1}: Correct!" : "Step ${index + 1}: $message"),
                ],
              ),
              backgroundColor: isCorrect ? Colors.green.withValues(alpha: 0.8) : Colors.red.withValues(alpha: 0.8),
              duration: const Duration(seconds: 1),
            ),
          );
        };
      } else if (game == 'javascript') {
        jsEngine = JSLogicGameEngine(
          () { setState(() {}); },
          onGameWon: _onGameWon,
          onGameLost: _onGameLost,
        );
        jsEngine!.currentLevel = level.toJson();
      } else if (game == 'sql') {
        sqlEngine = SQlGameEngine(
          () { setState(() {}); },
          onGameWon: _onGameWon,
          onGameLost: _onGameLost,
        );
        sqlEngine!.currentLevel = level.toJson();
      } else if (game == 'java') {
        javaEngine = JavaGameEngine(
          () { setState(() {}); },
          onGameWon: _onGameWon,
          onGameLost: _onGameLost,
        );
        javaEngine!.currentLevel = level.toJson();
      }
    });
  }
  
  void _onGameWon() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Level Complete! Great job!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _loadNextLevel(isWon: true);
    });
  }
  
  void _onGameLost() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Level Failed! Try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadNextLevel({bool isWon = true}) async {
    currentLevelIndex++;
    
    // Check if we've completed all 5 levels
    if (currentLevelIndex > 5) {
      if (mounted) {
        // Only show completion dialog if user WON the last level
        // If they SKIPPED, just go back to menu silently
        if (isWon) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('🏆 All Levels Completed!'),
              content: Text('You have successfully completed all 5 levels of ${selectedGame!.toUpperCase()}!\n\nGreat job mastering this skill!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      selectedGame = null;
                      currentLevelIndex = 1;
                    });
                  },
                  child: const Text('Back to Menu'),
                ),
              ],
            ),
          );
        } else {
          // Silently return to menu if skipped
          setState(() {
            selectedGame = null;
            currentLevelIndex = 1;
          });
        }
      }
      return;
    }

    final String nextId = "level_$currentLevelIndex";
    try {
      final nextLevel = await LevelLoader.loadLevel(selectedGame!, nextId);
      setState(() {
        currentLevel = nextLevel;
        currentCode = nextLevel.initialCode;
        aiHint = null;
        
        // Reset game state for next level
        if (selectedGame == 'python' && pythonEngine != null) {
          pythonEngine!.currentLevel = nextLevel;
          pythonEngine!.resetGameState();
        } else if (selectedGame == 'javascript' && jsEngine != null) {
          jsEngine!.currentLevel = nextLevel.toJson();
          jsEngine!.resetGameState();
        } else if (selectedGame == 'sql' && sqlEngine != null) {
          sqlEngine!.currentLevel = nextLevel.toJson();
          sqlEngine!.resetGameState();
        } else if (selectedGame == 'java' && javaEngine != null) {
          javaEngine!.currentLevel = nextLevel.toJson();
          javaEngine!.resetGameState();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading level: $e')),
        );
      }
    }
  }

  void _getAIHint() async {
    setState(() {
      isLoadingHint = true;
      aiHint = null;
    });

    // Strategy 1: Use the solution defined in the level file (Direct & Precise)
    if (currentLevel != null && currentLevel!.solution.isNotEmpty) {
      final solution = currentLevel!.solution;
      setState(() {
        isLoadingHint = false;
        aiHint = "Next step: ${solution[0]}";
      });
      return;
    }

    // Optimization: Skip API call for Level 1 as it's simple
    if (currentLevelIndex == 1) {
      setState(() {
        isLoadingHint = false;
        aiHint = "Try using the most basic commands first! For Python, 'move_right()' is a great start.";
      });
      return;
    }

    final hint = await gemini.getHint(
      language: selectedGame!,
      currentCode: currentCode,
      levelDescription: currentLevel?.description ?? "Level task",
    );

    setState(() {
      isLoadingHint = false;
      aiHint = hint;
    });
  }

  @override
  Widget build(BuildContext context) {
    String titleText = 'Coding Games';
    if (selectedGame != null) {
      if (selectedGame == 'python') {
        titleText = 'Python RPG';
      } else if (selectedGame == 'javascript') titleText = 'JS Logic';
      else if (selectedGame == 'sql') titleText = 'SQL Puzzle';
      else if (selectedGame == 'java') titleText = 'Java OOP';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titleText),
        leading: selectedGame != null 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  selectedGame = null;
                  currentLevelIndex = 1;
                });
              }
            )
          : null,
      ),
      body: selectedGame == null ? _buildGameSelection() : _buildGameStage(selectedGame!),
    );
  }

  Widget _buildGameSelection() {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildGameCard('Python RPG', Icons.terminal, AppColors.primaryPurple, 'python'),
        _buildGameCard('JS Logic', Icons.javascript, AppColors.accentOrange, 'javascript'),
        _buildGameCard('SQL Puzzle', Icons.storage, AppColors.primaryBlue, 'sql'),
        _buildGameCard('Java OOP', Icons.coffee, AppColors.accentGreen, 'java'),
      ],
    );
  }

  Widget _buildGameCard(String title, IconData icon, Color color, String id) {
    return GestureDetector(
      onTap: () => _selectGame(id),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        hasGlow: true,
        glowColor: color.withValues(alpha: 0.3),
        borderColor: color.withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStage(String gameId) {
    if (currentLevel == null) return const Center(child: CircularProgressIndicator());

    Widget gameWidget;
    String lang;

    switch (gameId) {
      case 'python':
        gameWidget = SizedBox(
          height: 300, 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GameWidget(
              game: pythonGame!,
            ),
          ),
        );
        // Apply level specific state if exists
        pythonGame?.updateLevelData(currentLevel!.initialGameState);
        lang = 'Python';
        break;
      case 'javascript':
        gameWidget = SizedBox(
          height: 300,
          child: JSLogicWidget(
            onGameWon: _onGameWon,
            onGameLost: _onGameLost,
            engine: jsEngine,
          ),
        );
        lang = 'JavaScript';
        break;
      case 'sql':
        gameWidget = SizedBox(
          height: 300,
          child: SQLPuzzleWidget(
            onGameWon: _onGameWon,
            onGameLost: _onGameLost,
            engine: sqlEngine,
          ),
        );
        lang = 'SQL';
        break;
      case 'java':
        gameWidget = SizedBox(
          height: 300,
          child: JavaOOPWidget(
            onGameWon: _onGameWon,
            onGameLost: _onGameLost,
            engine: javaEngine,
          ),
        );
        lang = 'Java';
        break;
      default:
        return const Center(child: Text('Unknown Game'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentLevelIndex == 1 && gameId == 'python') 
            _buildIntroCard("Welcome to Python RPG! Guide your knight using code. Reach the treasure chest to advance."),
          _buildLevelHeader(),
          const SizedBox(height: 16),
          gameWidget,
          const SizedBox(height: 16),
          if (aiHint != null) _buildHintBox(),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: CodeEditor(
              language: lang,
              initialCode: currentCode,
              onCodeChanged: (code) => currentCode = code,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Run Code',
                  onPressed: () {
                    debugPrint("[GameHub] Run Code pressed, gameId=$gameId, currentCode length=${currentCode.length}");
                    if (gameId == 'python') {
                      debugPrint("[GameHub] Running Python with code:\n$currentCode");
                      pythonEngine?.resetGameState();
                      pythonEngine?.startGame();
                      pythonEngine?.run(currentCode);
                    } else if (gameId == 'javascript') {
                      jsEngine?.resetGameState();
                      jsEngine?.startGame();
                      jsEngine?.run(currentCode);
                    } else if (gameId == 'sql') {
                      sqlEngine?.resetGameState();
                      sqlEngine?.startGame();
                      sqlEngine?.run(currentCode);
                    } else if (gameId == 'java') {
                      javaEngine?.resetGameState();
                      javaEngine?.startGame();
                      javaEngine?.run(currentCode);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                height: 50,
                child: FloatingActionButton(
                  onPressed: isLoadingHint ? null : _getAIHint,
                  backgroundColor: AppColors.primaryPurple,
                  child: isLoadingHint 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.lightbulb_outline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _loadNextLevel(isWon: false),
            child: const Text("Skip to Next Level", style: TextStyle(color: Colors.white24)),
          )
        ],
      ),
    );
  }

  Widget _buildLevelHeader() {
    final level = currentLevel!;
    double progress = currentLevelIndex / 5.0;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Level Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  level.title,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Lv. $currentLevelIndex/5",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            level.description,
            softWrap: true,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.primaryPurple.withValues(alpha: 0.5),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHintBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(aiHint!, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13))),
        ],
      ),
    );
  }
}
