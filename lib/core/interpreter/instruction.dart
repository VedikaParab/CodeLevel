/// Base class for all parsed instructions from any language
abstract class Instruction {
  /// Line number from the original code (for highlighting)
  final int lineNumber;

  Instruction(this.lineNumber);
}

/// Common instruction types that many games might share
class MoveInstruction extends Instruction {
  final String direction; // 'up', 'down', 'left', 'right'
  MoveInstruction(this.direction, super.lineNumber);
}

class ActionInstruction extends Instruction {
  final String action; // 'attack', 'collect', 'interact'
  ActionInstruction(this.action, super.lineNumber);
}

/// Represents an unresolved or syntax-error instruction
class ErrorInstruction extends Instruction {
  final String message;
  ErrorInstruction(this.message, super.lineNumber);
}

class SQLQueryInstruction extends Instruction {
  final String queryType; // 'SELECT', 'INSERT', etc.
  final String targetTable;
  final String rawQuery;
  SQLQueryInstruction(this.queryType, this.targetTable, this.rawQuery, super.lineNumber);
}

class ClassInstruction extends Instruction {
  final String className;
  ClassInstruction(this.className, super.lineNumber);
}

class MethodInstruction extends Instruction {
  final String methodName;
  final String objectName;
  MethodInstruction(this.methodName, this.objectName, super.lineNumber);
}
