import 'package:flutter/material.dart';

class CodeEditor extends StatefulWidget {
  final String language;
  final String initialCode;
  final void Function(String) onCodeChanged;
  final int? currentExecutingLine;

  const CodeEditor({
    Key? key,
    required this.language,
    required this.initialCode,
    required this.onCodeChanged,
    this.currentExecutingLine,
  }) : super(key: key);

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _controller.addListener(() {
      widget.onCodeChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCode != oldWidget.initialCode) {
      _controller.text = widget.initialCode;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For a real app, use something like flutter_highlight for true syntax highlighting.
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // VS Code dark background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.language.toUpperCase(),
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                color: Color(0xFFD4D4D4),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '// Write your code here...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
