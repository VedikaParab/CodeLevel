import '../../core/interpreter/instruction.dart';
import '../../core/interpreter/interpreter.dart';


class SQLInterpreter extends Interpreter {
  @override
  void parse(String code) {
    reset();
    final statements = code.split(';');
    for (int i = 0; i < statements.length; i++) {
      final stmt = statements[i].trim();
      if (stmt.isEmpty) continue;

      final upperStmt = stmt.toUpperCase();
      if (upperStmt.startsWith('SELECT')) {
        // Very rudimentary parsing
        // Expected: SELECT * FROM users or SELECT name FROM users
        final fromMatch = RegExp(r'FROM\s+(\w+)').firstMatch(upperStmt);
        if (fromMatch != null) {
          final table = fromMatch.group(1)!;
          instructions.add(SQLQueryInstruction('SELECT', table, stmt, i + 1));
        } else {
          instructions.add(ErrorInstruction("Missing FROM clause", i + 1));
        }
      } else if (upperStmt.startsWith('UPDATE') || upperStmt.startsWith('INSERT') || upperStmt.startsWith('DELETE')) {
        instructions.add(ErrorInstruction("Data modification queries not fully simulated yet.", i + 1));
      } else {
        instructions.add(ErrorInstruction("Unknown or unsupported SQL: $stmt", i + 1));
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
