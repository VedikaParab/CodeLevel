import 'dart:math';

import 'package:flutter/material.dart';

import '../models/mind_map_node.dart';
import '../theme/app_colors.dart';

class MindMapView extends StatefulWidget {
  final MindMapNode root;
  final String? activeFlowBlock;
  final ValueChanged<MindMapNode>? onNodeTap;

  const MindMapView({
    super.key,
    required this.root,
    this.activeFlowBlock,
    this.onNodeTap,
  });

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  static const Size _virtualSize = Size(1400, 900);
  static const double _nodeWidth = 132;
  static const double _nodeHeight = 44;

  late List<VisibleMindMapNode> _visible;

  @override
  void initState() {
    super.initState();
    _visible = _buildVisibleGraph(widget.root);
  }

  List<VisibleMindMapNode> _buildVisibleGraph(MindMapNode root) {
    final nodes = <VisibleMindMapNode>[];

    void walk(MindMapNode node, Offset pos, String? parentId, int depth) {
      nodes.add(
        VisibleMindMapNode(
          id: node.id,
          title: node.title,
          flowBlock: node.flowBlock,
          pos: pos,
          parentId: parentId,
          hasChildren: node.children.isNotEmpty,
        ),
      );

      if (!node.expanded || node.children.isEmpty) {
        return;
      }

      final count = node.children.length;
      final radius = 170.0 + depth * 35.0;
      final startAngle = -pi / 2.9;
      final endAngle = pi / 2.9;

      for (int i = 0; i < count; i++) {
        final t = count == 1 ? 0.5 : i / (count - 1);
        final angle = startAngle + (endAngle - startAngle) * t;
        final childPos = pos + Offset(cos(angle) * radius, sin(angle) * radius);
        walk(node.children[i], childPos, node.id, depth + 1);
      }
    }

    walk(root, const Offset(0, 0), null, 0);
    return nodes;
  }

  MindMapNode? _findNode(MindMapNode node, String id) {
    if (node.id == id) {
      return node;
    }
    for (final child in node.children) {
      final found = _findNode(child, id);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  void _onTapNode(VisibleMindMapNode visibleNode) {
    final node = _findNode(widget.root, visibleNode.id);
    if (node == null) {
      return;
    }

    setState(() {
      if (node.children.isNotEmpty) {
        node.expanded = !node.expanded;
      }
      _visible = _buildVisibleGraph(widget.root);
    });

    widget.onNodeTap?.call(node);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.35,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(220),
      child: SizedBox(
        width: _virtualSize.width,
        height: _virtualSize.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MindMapEdgesPainter(_visible)),
            ),
            for (final node in _visible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: _virtualSize.width / 2 + node.pos.dx - _nodeWidth / 2,
                top: _virtualSize.height / 2 + node.pos.dy - _nodeHeight / 2,
                child: GestureDetector(
                  onTap: () => _onTapNode(node),
                  child: _MindMapNodeChip(
                    title: node.title,
                    isActive:
                        node.flowBlock != null &&
                        node.flowBlock == widget.activeFlowBlock,
                    isExpandable: node.hasChildren,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MindMapEdgesPainter extends CustomPainter {
  final List<VisibleMindMapNode> nodes;

  _MindMapEdgesPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final node in nodes) node.id: node};
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.translate(size.width / 2, size.height / 2);

    for (final node in nodes) {
      if (node.parentId == null) {
        continue;
      }

      final parent = byId[node.parentId!];
      if (parent == null) {
        continue;
      }

      canvas.drawLine(parent.pos, node.pos, edgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapEdgesPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}

class _MindMapNodeChip extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isExpandable;

  const _MindMapNodeChip({
    required this.title,
    required this.isActive,
    required this.isExpandable,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryBlue.withValues(alpha: 0.45)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? AppColors.primaryBlue
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          if (isExpandable) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.control_point,
              size: 14,
              color: AppColors.accentGreen.withValues(alpha: 0.95),
            ),
          ],
        ],
      ),
    );
  }
}
