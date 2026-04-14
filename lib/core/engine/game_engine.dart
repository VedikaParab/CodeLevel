import 'package:flutter/foundation.dart';
import '../interpreter/instruction.dart';
import '../interpreter/interpreter.dart';

/// Base class for executing interpreted code step-by-step
abstract class GameEngine {
  final Interpreter interpreter;
  
  /// Delay between executing instructions (for visual feedback)
  Duration stepDelay;

  bool isRunning = false;
  bool isPaused = false;

  /// Callback for step validation result
  void Function(int index, bool isCorrect, String? message)? onStepResult;

  GameEngine(this.interpreter, {this.stepDelay = const Duration(milliseconds: 500)});

  /// Starts or resumes execution
  Future<void> run(String code) async {
    // Only stop the previous execution loop, don't reset game state
    // (game state was already reset by resetGameState() before this is called)
    isRunning = false;
    isPaused = false;
    interpreter.reset();
    // Important: Do NOT call resetGameState() here - it's already been called
    
    debugPrint("[GameEngine] Starting run() with code:\n$code");
    interpreter.parse(code);
    debugPrint("[GameEngine] Parsed ${interpreter.instructions.length} instructions");
    isRunning = true;
    isPaused = false;
    
    debugPrint("[GameEngine] Starting execution...");

    int instructionIndex = 0;
    while (isRunning && !isPaused && !interpreter.isFinished) {
      final  instruction = interpreter.step();
      debugPrint("[GameEngine] Step $instructionIndex: got instruction $instruction");
      if (instruction != null) {
        await executeInstruction(instruction, instructionIndex);
        instructionIndex++;
      }
      if (!interpreter.isFinished && isRunning) {
        await Future.delayed(stepDelay);
      }
    }
    debugPrint("[GameEngine] Execution finished. isFinished=${interpreter.isFinished}, isRunning=$isRunning");
  }

  /// Pauses execution
  void pause() {
    isPaused = true;
  }

  /// Stops and resets execution
  void stop() {
    isRunning = false;
    isPaused = false;
    interpreter.reset();
    resetGameState();
  }

  /// Each specific game implements how an underlying instruction modifies the game world
  Future<void> executeInstruction(Instruction instruction, int index);

  /// Resets the actual game objects (player position, health, etc.)
  void resetGameState();
}
