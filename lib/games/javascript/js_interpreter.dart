import '../../core/interpreter/instruction.dart';
import '../../core/interpreter/interpreter.dart';

class JSInterpreter extends Interpreter {
  // Simulating variables for JS logic
  final Map<String, dynamic> variables = {};

  @override
  void parse(String code) {
    reset();
    final cleanCode = code.replaceAll('\r', '');
    // Using RegExp for a very rough tokenizer.
    // In a production app, we would write a real Lexer -> AST Parser loop.
    final tokens = cleanCode.split(RegExp(r'[;\n]'));

    var i = 0;
    while (i < tokens.length) {
      final line = tokens[i].trim();
      if (line.isEmpty) {
        i++;
        continue;
      }

      if (line == 'moveRight()') {
        instructions.add(MoveInstruction('right', i + 1));
      } else if (line == 'moveLeft()') {
        instructions.add(MoveInstruction('left', i + 1));
      } else if (line == 'attack()') {
        instructions.add(ActionInstruction('attack', i + 1));
      } else if (line.startsWith('let ')) {
        // e.g. let x = 5
        final parts = line.split('=');
        if (parts.length == 2) {
          final varName = parts[0].replaceAll('let', '').trim();
          final val = parts[1].trim();
          variables[varName] = val;
          // ActionInstruction used generically for variable assignment feedback
          instructions.add(ActionInstruction('assign_$varName', i + 1));
        }
      } else {
        if (line.contains('if') || line.contains('while') || line.contains('{')) {
          instructions.add(ErrorInstruction('JS Block parsing not fully implemented in skeleton', i + 1));
        } else {
          instructions.add(ErrorInstruction('Syntax Error: \$line', i + 1));
        }
      }
      i++;
    }
  }

  @override
  Instruction? step() {
    if (isFinished || currentInstructionIndex >= instructions.length) {
      isFinished = true;
      currentLineNumber = null;
      return null;
    }

    final instruction = instructions[currentInstructionIndex];
    currentLineNumber = instruction.lineNumber;
    currentInstructionIndex++;

    if (currentInstructionIndex >= instructions.length) {
      isFinished = true;
    }

    return instruction;
  }
}
