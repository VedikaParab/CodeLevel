import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/engine/game_engine.dart';
import '../../core/interpreter/instruction.dart';
import '../../core/models/game_status.dart';
import '../../shared/level_system/level_loader.dart';
import 'python_interpreter.dart';

class PythonGameEngine extends GameEngine {
  final PythonGame flameGame;
  Level? currentLevel;
  GameStatus gameStatus = GameStatus.entry;
  VoidCallback? onGameWon;
  VoidCallback? onGameLost;

  PythonGameEngine(this.flameGame, {this.onGameWon, this.onGameLost}) : super(PythonInterpreter(), stepDelay: const Duration(seconds: 1));
  
  void startGame() {
    gameStatus = GameStatus.playing;
    flameGame.resetLevel();
  }

  @override
  Future<void> executeInstruction(Instruction instruction, int index) async {
    debugPrint("[PythonEngine] executeInstruction called: index=$index, gameStatus=$gameStatus");
    if (gameStatus != GameStatus.playing) {
      debugPrint("[PythonEngine] Game not in playing state. Current status: $gameStatus");
      return;
    }
    
    String? instructionName;
    if (instruction is MoveInstruction) {
      instructionName = 'move_${instruction.direction}';
    } else if (instruction is ActionInstruction) {
      instructionName = instruction.action;
    }

    bool isCorrect = false;
    if (currentLevel != null && currentLevel!.solution.isNotEmpty) {
      if (index < currentLevel!.solution.length) {
        isCorrect = instructionName == currentLevel!.solution[index];
        debugPrint("[PythonEngine] Validating: instructionName=$instructionName, expected=${currentLevel!.solution[index]}, isCorrect=$isCorrect");
      }
    } else {
      // If no solution is provided, fallback to standard execution (for debugging or new levels)
      isCorrect = true;
      debugPrint("[PythonEngine] No solution provided, fallback to true");
    }

    if (!isCorrect) {
      debugPrint("Python Error: Incorrect move at step $index. Expected ${currentLevel?.solution[index]}, got $instructionName");
      onStepResult?.call(index, false, "Incorrect move! Try again.");
      gameStatus = GameStatus.lost;
      onGameLost?.call();
      stop();
      return;
    }

    // If correct, show success for this step and proceed with animation
    onStepResult?.call(index, true, null);

    if (instruction is MoveInstruction) {
      await flameGame.player.move(instruction.direction);
    } else if (instruction is ActionInstruction) {
      if (instruction.action == 'attack') {
        await flameGame.player.attack();
      } else if (instruction.action == 'collect') {
        await flameGame.player.collect();
      }
    } else if (instruction is ErrorInstruction) {
      debugPrint("Python Error on line ${instruction.lineNumber}: ${instruction.message}");
      onStepResult?.call(index, false, instruction.message);
      gameStatus = GameStatus.lost;
      onGameLost?.call();
      stop();
      return;
    }

    // Check win condition ONLY if this was the last expected move in the solution
    bool isLastStep = currentLevel != null && index == currentLevel!.solution.length - 1;
    debugPrint("[PythonEngine] isLastStep=$isLastStep, currentLevelSolutionLength=${currentLevel?.solution.length}");
    
    if (isLastStep) {
      debugPrint("[PythonEngine] Last step reached, checking win condition");
      final playerPos = flameGame.player.position;
      final goalPos = flameGame.goal.position;
      debugPrint("[PythonEngine] Player position: $playerPos, Goal position: $goalPos");
      
      if (flameGame.checkWinCondition()) {
        debugPrint("[PythonEngine] WIN CONDITION MET!");
        gameStatus = GameStatus.won;
        onGameWon?.call();
        stop();
      } else {
        debugPrint("[PythonEngine] WIN CONDITION NOT MET");
        onStepResult?.call(index, false, "Reached the end of code but didn't reach the goal!");
        gameStatus = GameStatus.lost;
        onGameLost?.call();
        stop();
      }
    }
  }

  @override
  void resetGameState() {
    gameStatus = GameStatus.entry;
    flameGame.resetLevel();
  }
}

class PythonGame extends FlameGame {
  late Player player;
  late Goal goal;
  late SpriteComponent background;
  final double tileSize = 64.0;
  
  VoidCallback? onWin;
  Vector2? goalPosition;

  @override
  Future<void> onLoad() async {
    // Load background
    final bgSprite = await loadSprite('dungeon_bg.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: size,
    );
    add(background);

    // Goal
    final goalSprite = await loadSprite('chest.png');
    goal = Goal(
      sprite: goalSprite,
      size: Vector2.all(tileSize * 1.2),
      position: goalPosition ?? Vector2(tileSize * 5, tileSize * 1),
    );
    add(goal);

    // Player
    final playerSprite = await loadSprite('python_knight.png');
    player = Player(
      sprite: playerSprite,
      size: Vector2.all(tileSize * 1.5),
      position: Vector2(tileSize, tileSize),
    );
    add(player);
  }

  bool checkWinCondition() {
    // Basic collision check between player and goal
    return (player.position - goal.position).length < tileSize;
  }

  void resetLevel() {
    player.position = Vector2(tileSize, tileSize);
  }

  void updateLevelData(Map<String, dynamic> state) {
    if (state['goal_x'] != null && state['goal_y'] != null) {
      goalPosition = Vector2(state['goal_x'] * tileSize, state['goal_y'] * tileSize);
      if (isLoaded) {
        goal.position = goalPosition!;
      }
    }
  }
}

class Player extends SpriteComponent {
  Player({required Sprite sprite, required Vector2 size, required Vector2 position}) 
    : super(sprite: sprite, size: size, position: position);

  Future<void> move(String direction) async {
    final step = 64.0;
    debugPrint("Player moving: $direction");
    switch (direction) {
      case 'up': position.y -= step; break;
      case 'down': position.y += step; break;
      case 'left': position.x -= step; break;
      case 'right': position.x += step; break;
    }
    // Small delay to make movement visible
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> attack() async {
    scale = Vector2.all(1.2);
    await Future.delayed(const Duration(milliseconds: 200));
    scale = Vector2.all(1.0);
  }

  Future<void> collect() async {
    // Collect animation logic
  }
}

class Goal extends SpriteComponent {
  Goal({required Sprite sprite, required Vector2 size, required Vector2 position}) 
    : super(sprite: sprite, size: size, position: position);
}
