import 'dart:math';

import 'package:flutter/material.dart';

import '../models/visualization_content.dart';
import '../theme/app_colors.dart';

class ConceptGraphView extends StatefulWidget {
  final ConceptGraph graph;

  const ConceptGraphView({super.key, required this.graph});

  @override
  State<ConceptGraphView> createState() => _ConceptGraphViewState();
}

class _ConceptGraphViewState extends State<ConceptGraphView>
    with SingleTickerProviderStateMixin {
  static const Size _virtualSize = Size(2200, 1400);
  static const double _nodeWidth = 170;
  static const double _nodeHeight = 58;
  static const Offset _origin = Offset(260, 420);

  late Map<String, ConceptGraphNode> _nodesById;
  late Map<String, List<String>> _childrenById;
  late Set<String> _expandedNodeIds;
  late Map<String, Offset> _positions;
  late List<String> _visibleNodeIds;
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _flowAnimationController;
  bool _didInitialFit = false;
  String? _activeNodeId;

  @override
  void initState() {
    super.initState();
    _flowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _initializeGraph();
  }

  @override
  void didUpdateWidget(covariant ConceptGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph) {
      _initializeGraph();
      _didInitialFit = false;
    }
  }

  @override
  void dispose() {
    _flowAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _initializeGraph() {
    _nodesById = {for (final node in widget.graph.nodes) node.id: node};
    _childrenById = {};

    for (final relation in widget.graph.relations) {
      _childrenById
          .putIfAbsent(relation.from, () => <String>[])
          .add(relation.to);
    }

    _expandedNodeIds = {widget.graph.rootId};
    _activeNodeId = widget.graph.rootId;
    _recomputeVisibleGraph();
  }

  void _recomputeVisibleGraph() {
    final visited = <String>{};
    final visible = <String>[];
    final depths = <String, int>{widget.graph.rootId: 0};
    final queue = <String>[widget.graph.rootId];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current) || !_nodesById.containsKey(current)) {
        continue;
      }
      visible.add(current);

      if (!_expandedNodeIds.contains(current)) {
        continue;
      }

      final children = _childrenById[current] ?? const <String>[];
      for (final child in children) {
        if (!_nodesById.containsKey(child)) {
          continue;
        }
        depths[child] = min(depths[child] ?? 999, (depths[current] ?? 0) + 1);
        queue.add(child);
      }
    }

    final layers = <int, List<String>>{};
    for (final id in visible) {
      final depth = depths[id] ?? 0;
      layers.putIfAbsent(depth, () => <String>[]).add(id);
    }

    final positions = <String, Offset>{};
    final sortedDepths = layers.keys.toList()..sort();

    for (final depth in sortedDepths) {
      final ids = layers[depth]!;
      final count = ids.length;

      final availableHeight = _virtualSize.height - 80;
      final dynamicSpacing = count <= 1
          ? 100.0
          : (availableHeight / (count - 1)).clamp(72.0, 118.0);

      for (var index = 0; index < count; index++) {
        final ySpacing = dynamicSpacing;
        final xSpacing = 220.0;
        final totalHeight = (count - 1) * ySpacing;
        final y = _origin.dy + (index * ySpacing) - (totalHeight / 2);
        final x = _origin.dx + depth * xSpacing;
        positions[ids[index]] = Offset(x, y);
      }
    }

    _visibleNodeIds = visible;
    _positions = positions;
  }

  void _toggleNode(String nodeId) {
    setState(() {
      _activeNodeId = nodeId;
      if (_expandedNodeIds.contains(nodeId)) {
        _expandedNodeIds.remove(nodeId);
      } else {
        _expandedNodeIds.add(nodeId);
      }
      _recomputeVisibleGraph();
      _didInitialFit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleInitialFit(constraints.maxWidth, constraints.maxHeight);

        return InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          panEnabled: true,
          panAxis: PanAxis.free,
          scaleEnabled: true,
          minScale: 0.25,
          maxScale: 2.8,
          clipBehavior: Clip.none,
          boundaryMargin: const EdgeInsets.all(900),
          child: SizedBox(
            width: _virtualSize.width,
            height: _virtualSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _flowAnimationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ConceptGraphEdgesPainter(
                          nodeIds: _visibleNodeIds,
                          positions: _positions,
                          relations: widget.graph.relations,
                          flowPhase: _flowAnimationController.value,
                        ),
                      );
                    },
                  ),
                ),
                for (final nodeId in _visibleNodeIds) _buildNode(nodeId),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scheduleInitialFit(double viewWidth, double viewHeight) {
    if (_didInitialFit || _visibleNodeIds.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitialFit) {
        return;
      }

      final bounds = _computeVisibleBounds();
      if (bounds == null) {
        return;
      }

      final targetWidth = max(bounds.width + 120, 1);
      final targetHeight = max(bounds.height + 120, 1);
      final scaleX = viewWidth / targetWidth;
      final scaleY = viewHeight / targetHeight;
      final scale = min(scaleX, scaleY).clamp(0.35, 1.0);

      final tx =
          (viewWidth - targetWidth * scale) / 2 - (bounds.left - 60) * scale;
      final ty =
          (viewHeight - targetHeight * scale) / 2 - (bounds.top - 60) * scale;

      _transformationController.value = Matrix4.identity()
        ..translate(tx, ty)
        ..scale(scale);

      _didInitialFit = true;
    });
  }

  Rect? _computeVisibleBounds() {
    if (_visibleNodeIds.isEmpty) {
      return null;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final nodeId in _visibleNodeIds) {
      final center = _positions[nodeId];
      if (center == null) {
        continue;
      }

      final left = center.dx - _nodeWidth / 2;
      final top = center.dy - _nodeHeight / 2;
      final right = center.dx + _nodeWidth / 2;
      final bottom = center.dy + _nodeHeight / 2;

      minX = min(minX, left);
      minY = min(minY, top);
      maxX = max(maxX, right);
      maxY = max(maxY, bottom);
    }

    if (minX == double.infinity) {
      return null;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Widget _buildNode(String nodeId) {
    final node = _nodesById[nodeId]!;
    final pos = _positions[nodeId] ?? Offset.zero;
    final hasChildren = (_childrenById[nodeId] ?? const <String>[]).isNotEmpty;
    final isExpanded = _expandedNodeIds.contains(nodeId);
    final isActive = _activeNodeId == nodeId;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      left: pos.dx - _nodeWidth / 2,
      top: pos.dy - _nodeHeight / 2,
      child: GestureDetector(
        onTap: () => _toggleNode(nodeId),
        child: Container(
          width: _nodeWidth,
          constraints: const BoxConstraints(minHeight: _nodeHeight),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryBlue.withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryBlue
                  : Colors.white.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                node.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.cognitive,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              if (hasChildren)
                Icon(
                  isExpanded
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: AppColors.accentGreen,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConceptGraphEdgesPainter extends CustomPainter {
  final List<String> nodeIds;
  final Map<String, Offset> positions;
  final List<ConceptGraphRelation> relations;
  final double flowPhase;

  _ConceptGraphEdgesPainter({
    required this.nodeIds,
    required this.positions,
    required this.relations,
    required this.flowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visibleSet = nodeIds.toSet();
    for (var index = 0; index < relations.length; index++) {
      final relation = relations[index];
      if (!visibleSet.contains(relation.from) ||
          !visibleSet.contains(relation.to)) {
        continue;
      }

      final from = positions[relation.from];
      final to = positions[relation.to];
      if (from == null || to == null) {
        continue;
      }

      final relationType = relation.type.toLowerCase();
      final isFlow =
          relationType.contains('flow') ||
          relationType.contains('leads') ||
          relationType.contains('sequence');

      if (isFlow) {
        _drawFlowEdge(canvas, from, to, relation, index);
      } else {
        _drawHierarchyEdge(canvas, from, to, relation);
      }
    }
  }

  void _drawHierarchyEdge(
    Canvas canvas,
    Offset from,
    Offset to,
    ConceptGraphRelation relation,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, paint);
    _drawRelationLabel(canvas, from, to, relation);
  }

  void _drawFlowEdge(
    Canvas canvas,
    Offset from,
    Offset to,
    ConceptGraphRelation relation,
    int index,
  ) {
    final pulse = (sin((flowPhase * 2 * pi) + index) + 1) / 2;

    final paint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.55 + 0.25 * pulse)
      ..strokeWidth = 2.0 + 0.9 * pulse
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, paint);

    final t = (flowPhase + index * 0.11) % 1.0;
    final dot = Offset.lerp(from, to, t) ?? from;
    canvas.drawCircle(
      dot,
      2.8,
      Paint()..color = AppColors.accentGreen.withValues(alpha: 0.9),
    );

    _drawArrowHead(canvas, from, to, paint.color);
    _drawRelationLabel(canvas, from, to, relation);
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Color color) {
    final direction = to - from;
    if (direction.distance < 0.01) {
      return;
    }

    final unit = direction / direction.distance;
    final arrowLength = 11.0;
    final arrowWidth = 6.0;
    final normal = Offset(-unit.dy, unit.dx);

    final tip = to;
    final base = tip - unit * arrowLength;
    final left = base + normal * arrowWidth;
    final right = base - normal * arrowWidth;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawRelationLabel(
    Canvas canvas,
    Offset from,
    Offset to,
    ConceptGraphRelation relation,
  ) {
    final text = (relation.label.isNotEmpty ? relation.label : relation.type)
        .replaceAll('_', ' ');
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 120);

    final padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    final labelOffset = Offset(
      mid.dx - textPainter.width / 2 - padding.horizontal / 2,
      mid.dy - textPainter.height / 2 - padding.vertical / 2,
    );

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        labelOffset.dx,
        labelOffset.dy,
        textPainter.width + padding.horizontal,
        textPainter.height + padding.vertical,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      bgRect,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    textPainter.paint(canvas, labelOffset + Offset(padding.left, padding.top));
  }

  @override
  bool shouldRepaint(covariant _ConceptGraphEdgesPainter oldDelegate) {
    return oldDelegate.nodeIds != nodeIds ||
        oldDelegate.positions != positions ||
        oldDelegate.relations != relations ||
        oldDelegate.flowPhase != flowPhase;
  }
}
