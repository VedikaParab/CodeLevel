import 'package:flutter/material.dart';
import '../../core/engine/game_engine.dart';
import '../../core/interpreter/instruction.dart';
import '../../core/models/game_status.dart';
import 'js_interpreter.dart';

class JSLogicGameEngine extends GameEngine {
  final VoidCallback onStateUpdate;
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  
  List<String> logs = [];
  bool doorUnlocked = false;
  GameStatus gameStatus = GameStatus.entry;
  int requiredActions = 3; // Win criterion: must perform 3 correct actions
  Map<String, dynamic> currentLevel = {}; // Level data

  JSLogicGameEngine(this.onStateUpdate, {this.onGameWon, this.onGameLost}) : super(JSInterpreter(), stepDelay: const Duration(milliseconds: 800));
  
  void startGame() {
    gameStatus = GameStatus.playing;
    logs.clear();
    doorUnlocked = false;
    onStateUpdate();
  }

  @override
  Future<void> executeInstruction(Instruction instruction, int index) async {
    if (gameStatus != GameStatus.playing) return;
    
    String? instructionName;
    if (instruction is MoveInstruction) {
      logs.add("Moved \${instruction.direction}");
      instructionName = 'move_\${instruction.direction}';
    } else if (instruction is ActionInstruction) {
      if (instruction.action.startsWith('assign_')) {
        logs.add("Variable Assigned.");
      } else {
        logs.add("Action: \${instruction.action}");
      }
      instructionName = instruction.action;
    } else if (instruction is ErrorInstruction) {
      logs.add("Error: \${instruction.message}");
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
          doorUnlocked = true;
          gameStatus = GameStatus.won;
          onGameWon?.call();
          stop();
        }
      }
    } else {
      // Fallback: check winning criteria based on action count
      if (logs.length >= requiredActions) {
        doorUnlocked = true;
        gameStatus = GameStatus.won;
        onGameWon?.call();
        stop();
      }
    }

    onStateUpdate();
  }

  @override
  void resetGameState() {
    logs.clear();
    doorUnlocked = false;
    gameStatus = GameStatus.entry;
    onStateUpdate();
  }
}

class JSLogicWidget extends StatefulWidget {
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  final JSLogicGameEngine? engine;
  
  const JSLogicWidget({super.key, this.onGameWon, this.onGameLost, this.engine});

  @override
  _JSLogicWidgetState createState() => _JSLogicWidgetState();
}

class _JSLogicWidgetState extends State<JSLogicWidget> {
  late JSLogicGameEngine engine;

  @override
  void initState() {
    super.initState();
    if (widget.engine != null) {
      engine = widget.engine!;
    } else {
      engine = JSLogicGameEngine(
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
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/images/dungeon_bg.png'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/js_wizard.png',
                  height: 120,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Icon(
                  engine.doorUnlocked ? Icons.door_back_door_outlined : Icons.door_front_door_outlined,
                  color: engine.doorUnlocked ? Colors.green : Colors.red,
                  size: 48,
                ),
              ),
              if (engine.gameStatus == GameStatus.entry)
                Positioned(
                  top: 10,
                  left: 10,
                  child: ElevatedButton(
                    onPressed: () => engine.startGame(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Start Game'),
                  ),
                )
              else
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Status: ${engine.gameStatus.name.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: engine.gameStatus == GameStatus.won ? Colors.greenAccent : 
                               engine.gameStatus == GameStatus.lost ? Colors.redAccent : Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: engine.logs.length,
              itemBuilder: (context, index) {
                return Text(
                  "> \${engine.logs[index]}",
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
