import '../../core/interpreter/instruction.dart';
import '../../core/interpreter/interpreter.dart';

class JavaClassModel {
  final String name;
  final List<String> fields = [];
  final List<String> methods = [];

  JavaClassModel(this.name);
}

class JavaInterpreter extends Interpreter {
  final Map<String, JavaClassModel> classes = {};

  @override
  void parse(String code) {
    reset();
    final lines = code.split('\n');
    String? currentClass;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('class ')) {
        final className = line.replaceAll('class', '').replaceAll('{', '').trim();
        currentClass = className;
        classes[className] = JavaClassModel(className);
        instructions.add(ClassInstruction(className, i + 1));
      } else if (line.endsWith('}')) {
        currentClass = null;
      } else if (currentClass != null) {
        if (line.contains('(') && (line.endsWith('){}') || line.endsWith(') {'))) {
          // Method - could be "void move() {" or "void move(){}"
          classes[currentClass]?.methods.add(line);
          final methodName = line.split('(')[0].replaceAll('void', '').replaceAll('public', '').replaceAll('private', '').trim();
          if (methodName.isNotEmpty) {
            instructions.add(MethodInstruction(methodName, 'this', i + 1));
          }
        } else if (line.endsWith(';')) {
          // Field
          classes[currentClass]?.fields.add(line);
        } else if (!line.endsWith('}')) {
          instructions.add(ErrorInstruction("Compile Error: Missing semicolon or invalid syntax", i + 1));
        }
      } else {
        if (line.contains('new ')) {
           // Simulate instantiation
           instructions.add(ClassInstruction("Instantiation: $line", i+1));
        } else if (line.contains('.')) {
          final parts = line.split('.');
          instructions.add(MethodInstruction(parts[1].replaceAll('();',''), parts[0], i + 1));
        } else {
           instructions.add(ErrorInstruction("Code outside of class context: $line", i + 1));
        }
      }
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
