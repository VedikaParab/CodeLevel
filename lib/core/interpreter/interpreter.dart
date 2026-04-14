import 'instruction.dart';

/// Base class for all language interpreters (Python, JS, SQL, Java)
abstract class Interpreter {
  /// Current list of parsed instructions
  List<Instruction> instructions = [];

  /// Current instruction index being executed
  int currentInstructionIndex = 0;

  /// Line number currently active (for UI highlighting)
  int? currentLineNumber;

  /// Whether the execution has finished
  bool isFinished = false;

  /// Parses raw code string into a list of [Instruction]s
  void parse(String code);

  /// Resets the interpreter state
  void reset() {
    instructions.clear();
    currentInstructionIndex = 0;
    currentLineNumber = null;
    isFinished = false;
  }

  /// Evaluates the next instruction and returns it.
  /// Returns null if finished.
  Instruction? step();
}
