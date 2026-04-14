import 'package:flutter/material.dart';

class MindMapNode {
  final String id;
  final String title;
  final String? flowBlock;
  final List<MindMapNode> children;
  bool expanded;

  MindMapNode({
    required this.id,
    required this.title,
    this.flowBlock,
    this.children = const [],
    this.expanded = false,
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = (json['children'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return MindMapNode(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      flowBlock: json['flowBlock']?.toString(),
      expanded: json['expanded'] == true,
      children: rawChildren.map(MindMapNode.fromJson).toList(),
    );
  }
}

class VisibleMindMapNode {
  final String id;
  final String title;
  final String? flowBlock;
  final Offset pos;
  final String? parentId;
  final bool hasChildren;

  VisibleMindMapNode({
    required this.id,
    required this.title,
    required this.pos,
    required this.hasChildren,
    this.parentId,
    this.flowBlock,
  });
}
