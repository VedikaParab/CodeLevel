class ExecutionStep {
  final int step;
  final int highlightedLine;
  final String flowBlock;
  final Map<String, dynamic> memory;
  final String output;
  final String explanation;

  ExecutionStep({
    required this.step,
    required this.highlightedLine,
    required this.flowBlock,
    required this.memory,
    required this.output,
    required this.explanation,
  });

  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    return ExecutionStep(
      step: json['step'],
      highlightedLine: json['highlightedLine'],
      flowBlock: json['flowBlock'],
      memory: Map<String, dynamic>.from(json['memory'] ?? {}),
      output: json['output'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
