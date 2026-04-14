import 'package:flutter/material.dart';
import '../../core/engine/game_engine.dart';
import '../../core/interpreter/instruction.dart';
import '../../core/models/game_status.dart';
import 'java_interpreter.dart';

class JavaGameEngine extends GameEngine {
  final List<String> executionSteps = [];
  final List<String> compileErrors = [];
  final VoidCallback onStateUpdate;
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  
  GameStatus gameStatus = GameStatus.entry;
  int expectedSteps = 3; // Win criterion: must execute exactly 3 steps
  Map<String, dynamic> currentLevel = {}; // Level data

  JavaGameEngine(this.onStateUpdate, {this.onGameWon, this.onGameLost}) : super(JavaInterpreter(), stepDelay: const Duration(seconds: 1));
  
  void startGame() {
    gameStatus = GameStatus.playing;
    executionSteps.clear();
    compileErrors.clear();
    onStateUpdate();
  }

  @override
  Future<void> executeInstruction(Instruction instruction, int index) async {
    if (gameStatus != GameStatus.playing) return;
    
    String? instructionName;
    if (instruction is ClassInstruction) {
      executionSteps.add("Defined class: ${instruction.className}");
      instructionName = 'class_${instruction.className}';
    } else if (instruction is MethodInstruction) {
      executionSteps.add("Invoked method: ${instruction.methodName} on ${instruction.objectName}");
      instructionName = 'method_${instruction.methodName}';
    } else if (instruction is ErrorInstruction) {
      compileErrors.add("Compile Error: \${instruction.message}");
      gameStatus = GameStatus.lost;
      onGameLost?.call();
      stop();
      onStateUpdate();
      return;
    }
    
    // Validate against solution if available, similar to Python
    if (currentLevel.isNotEmpty && currentLevel['solution'] != null) {
      final solution = List<String>.from(currentLevel['solution'] ?? []);
      if (solution.isNotEmpty) {
        bool isCorrect = false;
        if (index < solution.length && instructionName != null) {
          isCorrect = instructionName == solution[index];
        }
        
        if (!isCorrect) {
          gameStatus = GameStatus.lost;
          onGameLost?.call();
          stop();
          onStateUpdate();
          return;
        }
        
        // Check if this was the last step
        bool isLastStep = index == solution.length - 1;
        if (isLastStep) {
          gameStatus = GameStatus.won;
          onGameWon?.call();
          stop();
        }
      }
    } else {
      // Fallback: check winning criteria based on step count
      if (executionSteps.length == expectedSteps) {
        gameStatus = GameStatus.won;
        onGameWon?.call();
        stop();
      }
    }
    onStateUpdate();
  }

  @override
  void resetGameState() {
    executionSteps.clear();
    compileErrors.clear();
    gameStatus = GameStatus.entry;
    onStateUpdate();
  }
}

class JavaOOPWidget extends StatefulWidget {
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  final JavaGameEngine? engine;
  
  const JavaOOPWidget({super.key, this.onGameWon, this.onGameLost, this.engine});

  @override
  State<JavaOOPWidget> createState() => _JavaOOPWidgetState();
}

class _JavaOOPWidgetState extends State<JavaOOPWidget> {
  late JavaGameEngine engine;

  @override
  void initState() {
    super.initState();
    if (widget.engine != null) {
      engine = widget.engine!;
    } else {
      engine = JavaGameEngine(
        () { setState(() {}); },
        onGameWon: () => _showGameResult(true),
        onGameLost: () => _showGameResult(false),
      );
    }
  }
  
  void _showGameResult(bool isWon) {
    if (isWon) {
      widget.onGameWon?.call();
    } else {
      widget.onGameLost?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.brown.shade900,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.brown.shade800, Colors.black],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Architect's Workspace", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text("Structure your classes and instantiate objects to complete the blueprint.", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      if (engine.gameStatus == GameStatus.entry)
                        ElevatedButton(
                          onPressed: () => engine.startGame(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Start Game'),
                        )
                      else
                        Text(
                          'Status: ${engine.gameStatus.name.toUpperCase()}',
                          style: TextStyle(
                            color: engine.gameStatus == GameStatus.won ? Colors.greenAccent : 
                                   engine.gameStatus == GameStatus.lost ? Colors.redAccent : Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset('assets/images/java_architect.png', height: 140),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("COMPILER OUTPUT", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 12)),
                const Divider(color: Colors.white24),
                Expanded(
                  child: ListView.builder(
                    itemCount: (engine.compileErrors.isNotEmpty ? engine.compileErrors.length : engine.executionSteps.length),
                    itemBuilder: (context, index) {
                      final text = engine.compileErrors.isNotEmpty ? engine.compileErrors[index] : engine.executionSteps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: engine.compileErrors.isNotEmpty ? Colors.redAccent : Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
