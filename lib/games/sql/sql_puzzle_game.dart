import 'package:flutter/material.dart';
import '../../core/engine/game_engine.dart';
import '../../core/interpreter/instruction.dart';
import '../../core/models/game_status.dart';
import 'sql_interpreter.dart';

class SQlGameEngine extends GameEngine {
  final Map<String, List<Map<String, dynamic>>> database = {
    'USERS': [
      {'id': 1, 'name': 'Alice', 'role': 'Admin'},
      {'id': 2, 'name': 'Bob', 'role': 'User'},
      {'id': 3, 'name': 'Charlie', 'role': 'Guest'},
      {'id': 4, 'name': 'Diana', 'role': 'Admin'},
      {'id': 5, 'name': 'Eve', 'role': 'User'},
      {'id': 6, 'name': 'Frank', 'role': 'User'},
      {'id': 7, 'name': 'Grace', 'role': 'Admin'},
      {'id': 8, 'name': 'Henry', 'role': 'Guest'},
      {'id': 9, 'name': 'Iris', 'role': 'User'},
      {'id': 10, 'name': 'Jack', 'role': 'Guest'},
      {'id': 11, 'name': 'Kate', 'role': 'Admin'},
      {'id': 12, 'name': 'Leo', 'role': 'User'},
    ],
    'ORDERS': [
      {'id': 101, 'user': 'Alice', 'amount': 150.00},
      {'id': 102, 'user': 'Bob', 'amount': 75.50},
      {'id': 103, 'user': 'Charlie', 'amount': 200.00},
      {'id': 104, 'user': 'Diana', 'amount': 125.75},
      {'id': 105, 'user': 'Eve', 'amount': 89.99},
      {'id': 106, 'user': 'Frank', 'amount': 320.00},
      {'id': 107, 'user': 'Grace', 'amount': 45.50},
      {'id': 108, 'user': 'Henry', 'amount': 199.99},
      {'id': 109, 'user': 'Iris', 'amount': 67.25},
      {'id': 110, 'user': 'Jack', 'amount': 234.80},
      {'id': 111, 'user': 'Kate', 'amount': 412.00},
      {'id': 112, 'user': 'Leo', 'amount': 156.30},
    ],
    'PRODUCTS': [
      {'id': 1, 'name': 'Widget', 'price': 9.99},
      {'id': 2, 'name': 'Gadget', 'price': 19.99},
      {'id': 3, 'name': 'Tool', 'price': 29.99},
      {'id': 4, 'name': 'Device', 'price': 49.99},
      {'id': 5, 'name': 'Component', 'price': 15.50},
      {'id': 6, 'name': 'Module', 'price': 35.75},
      {'id': 7, 'name': 'System', 'price': 99.99},
      {'id': 8, 'name': 'Unit', 'price': 24.50},
      {'id': 9, 'name': 'Part', 'price': 12.00},
      {'id': 10, 'name': 'Element', 'price': 39.99},
      {'id': 11, 'name': 'Assembly', 'price': 89.50},
      {'id': 12, 'name': 'Kit', 'price': 59.99},
    ]
  };

  List<Map<String, dynamic>> queryResults = [];
  String? errorMessage;
  final VoidCallback onStateUpdate;
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  
  GameStatus gameStatus = GameStatus.entry;
  int expectedResultCount = 3; // Win: retrieve exactly 3 records
  Map<String, dynamic> currentLevel = {}; // Level data

  SQlGameEngine(this.onStateUpdate, {this.onGameWon, this.onGameLost}) : super(SQLInterpreter(), stepDelay: const Duration(milliseconds: 500));
  
  void startGame() {
    gameStatus = GameStatus.playing;
    queryResults.clear();
    errorMessage = null;
    onStateUpdate();
  }

  @override
  Future<void> executeInstruction(Instruction instruction, int index) async {
    if (gameStatus != GameStatus.playing) return;
    
    if (instruction is SQLQueryInstruction) {
      if (instruction.queryType == 'SELECT') {
        final tableData = database[instruction.targetTable.toUpperCase()];
        if (tableData != null) {
          queryResults = List.from(tableData);
          
          // Validate against solution if available
          if (currentLevel.isNotEmpty && currentLevel['solution'] != null) {
            final solution = List<String>.from(currentLevel['solution'] ?? []);
            if (solution.isNotEmpty) {
              final expectedTable = solution[0].toUpperCase();
              if (instruction.targetTable.toUpperCase() != expectedTable) {
                errorMessage = "Incorrect table queried. Expected \$expectedTable, got \${instruction.targetTable}.";
                gameStatus = GameStatus.lost;
                onGameLost?.call();
                stop();
                onStateUpdate();
                return;
              }
              gameStatus = GameStatus.won;
              onGameWon?.call();
              stop();
            }
          } else {
            // Fallback: check winning criteria based on result count
            if (queryResults.length == expectedResultCount) {
              gameStatus = GameStatus.won;
              onGameWon?.call();
              stop();
            }
          }
        } else {
          errorMessage = "Table \${instruction.targetTable} does not exist.";
          gameStatus = GameStatus.lost;
          onGameLost?.call();
          stop();
        }
      }
    } else if (instruction is ErrorInstruction) {
      errorMessage = instruction.message;
      gameStatus = GameStatus.lost;
      onGameLost?.call();
      stop();
    }
    
    onStateUpdate();
  }

  @override
  void resetGameState() {
    queryResults.clear();
    errorMessage = null;
    gameStatus = GameStatus.entry;
    onStateUpdate();
  }
}

class SQLPuzzleWidget extends StatefulWidget {
  final VoidCallback? onGameWon;
  final VoidCallback? onGameLost;
  final SQlGameEngine? engine;
  
  const SQLPuzzleWidget({super.key, this.onGameWon, this.onGameLost, this.engine});

  @override
  _SQLPuzzleWidgetState createState() => _SQLPuzzleWidgetState();
}

class _SQLPuzzleWidgetState extends State<SQLPuzzleWidget> {
  late SQlGameEngine engine;

  @override
  void initState() {
    super.initState();
    if (widget.engine != null) {
      engine = widget.engine!;
    } else {
      engine = SQlGameEngine(
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/sql_archivist.png', height: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Query the database",
                      softWrap: true,
                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (engine.gameStatus == GameStatus.entry)
                      ElevatedButton(
                        onPressed: () => engine.startGame(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text('Start Game'),
                      )
                    else
                      Text(
                        'Status: ${engine.gameStatus.name.toUpperCase()}',
                        style: TextStyle(
                          color: engine.gameStatus == GameStatus.won ? Colors.greenAccent : 
                                 engine.gameStatus == GameStatus.lost ? Colors.redAccent : Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (engine.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.withValues(alpha: 0.2),
            child: Text(engine.errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(8),
            child: engine.queryResults.isEmpty
                ? _buildTablePreview(context)
                : _buildResultsTable(),
          ),
        )
      ],
    );
  }

  Widget _buildTablePreview(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Available Tables:",
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          _buildTableSection("USERS", engine.database['USERS']!, ['id', 'name', 'role']),
          const SizedBox(height: 16),
          _buildTableSection("ORDERS", engine.database['ORDERS']!, ['id', 'user', 'amount']),
          const SizedBox(height: 16),
          _buildTableSection("PRODUCTS", engine.database['PRODUCTS']!, ['id', 'name', 'price']),
        ],
      ),
    );
  }

  Widget _buildTableSection(String tableName, List<Map<String, dynamic>> data, List<String> columns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tableName,
          style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            dataRowHeight: 32,
            headingRowHeight: 32,
            columns: columns.map((col) => DataColumn(label: Text(col, style: const TextStyle(color: Colors.blue, fontSize: 11)))).toList(),
            rows: data.take(3).map((row) {
              return DataRow(cells: columns.map((col) => DataCell(Text(row[col.toLowerCase()].toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)))).toList());
            }).toList(),
          ),
        ),
        Text(
          '... and ${data.length - 3} more rows',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildResultsTable() {
    var columns = ['id', 'name', 'role'];
    return DataTable(
      columns: columns.map((col) => DataColumn(label: Text(col.toUpperCase(), style: const TextStyle(color: Colors.blue)))).toList(),
      rows: engine.queryResults.map((row) {
        return DataRow(cells: columns.map((col) => DataCell(Text(row[col].toString(), style: const TextStyle(color: Colors.white)))).toList());
      }).toList(),
    );
  }
}
