import '../../core/interpreter/instruction.dart';
import '../../core/interpreter/interpreter.dart';
import 'package:flutter/foundation.dart';

class PythonInterpreter extends Interpreter {
  @override
  void parse(String code) {
    reset();
    debugPrint("[PythonInterpreter] Parsing code: $code");
    final lines = code.split('\n');
    debugPrint("[PythonInterpreter] Split into ${lines.length} lines");

    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trim().toLowerCase();
      
      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) {
        i++;
        continue;
      }

      // Handle for loops: for i in range(N):
      if (line.startsWith('for ')) {
        debugPrint("[PythonInterpreter] Found for loop at line $i");
        final rangeMatch = RegExp(r'range\((\d+)\)').firstMatch(line);
        
        if (rangeMatch != null) {
          final count = int.parse(rangeMatch.group(1)!);
          debugPrint("[PythonInterpreter] Extracted count=$count from range");
          
          // Collect indented block (loop body)
          List<String> loopBody = [];
          int j = i + 1;
          while (j < lines.length) {
            final bodyLine = lines[j];
            // Check if line is indented (starts with space or tab) and not empty
            if (bodyLine.startsWith(RegExp(r'\s+')) && bodyLine.trim().isNotEmpty && !bodyLine.trim().startsWith('#')) {
              loopBody.add(bodyLine.trim());
              debugPrint("[PythonInterpreter] Added loop body line: ${bodyLine.trim()}");
              j++;
            } else {
              break;
            }
          }
          
          // Repeat loop body N times
          for (int rep = 0; rep < count; rep++) {
            debugPrint("[PythonInterpreter] Loop iteration $rep");
            for (String bodyLine in loopBody) {
              final bodyLineLower = bodyLine.toLowerCase();
              _addInstructionFromLine(bodyLineLower, i + 1);
            }
          }
          
          // Skip processed lines
          i = j;
          continue;
        } else {
          instructions.add(ErrorInstruction('Invalid for loop syntax. Use: for i in range(N):', i + 1));
          debugPrint("[PythonInterpreter] Invalid for loop syntax");
          i++;
          continue;
        }
      }
      
      // Handle regular instructions
      _addInstructionFromLine(line, i + 1);
      i++;
    }
  }

  /// Helper method to add instruction from a single line
  void _addInstructionFromLine(String line, int lineNumber) {
    if (line.startsWith('move_right')) {
      instructions.add(MoveInstruction('right', lineNumber));
      debugPrint("[PythonInterpreter] Added move_right instruction");
    } else if (line.startsWith('move_left')) {
      instructions.add(MoveInstruction('left', lineNumber));
      debugPrint("[PythonInterpreter] Added move_left instruction");
    } else if (line.startsWith('move_up')) {
      instructions.add(MoveInstruction('up', lineNumber));
      debugPrint("[PythonInterpreter] Added move_up instruction");
    } else if (line.startsWith('move_down')) {
      instructions.add(MoveInstruction('down', lineNumber));
      debugPrint("[PythonInterpreter] Added move_down instruction");
    } else if (line.startsWith('attack')) {
      instructions.add(ActionInstruction('attack', lineNumber));
      debugPrint("[PythonInterpreter] Added attack instruction");
    } else if (line.startsWith('collect')) {
      instructions.add(ActionInstruction('collect', lineNumber));
      debugPrint("[PythonInterpreter] Added collect instruction");
    } else if (line.isNotEmpty && !line.startsWith('#')) {
      // Treat unknown commands as errors
      if (line.contains('while ') || line.contains('if ')) {
        instructions.add(ErrorInstruction('While and if statements not yet supported', lineNumber));
        debugPrint("[PythonInterpreter] Added error instruction: unsupported control flow");
      } else {
        instructions.add(ErrorInstruction('Unknown command: $line', lineNumber));
        debugPrint("[PythonInterpreter] Added error instruction: unknown command '$line'");
      }
    }
  }

  @override
  Instruction? step() {
    if (isFinished || currentInstructionIndex >= instructions.length) {
      isFinished = true;
      currentLineNumber = null;
      debugPrint("[PythonInterpreter] step() returning null, isFinished=true");
      return null;
    }

    final instruction = instructions[currentInstructionIndex];
    currentLineNumber = instruction.lineNumber;
    debugPrint("[PythonInterpreter] step() returning instruction at index $currentInstructionIndex: $instruction");
    currentInstructionIndex++;

    if (currentInstructionIndex >= instructions.length) {
      isFinished = true;
    }

    return instruction;
  }
}
