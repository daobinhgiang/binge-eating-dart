import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weight_diary_provider.dart';

class WeightGraphWidget extends ConsumerWidget {
  final String userId;
  final VoidCallback? onTap;
  final double height;
  final bool showTitle;
  final bool showAxisLabels;

  const WeightGraphWidget({
    super.key,
    required this.userId,
    this.onTap,
    this.height = 200,
    this.showTitle = true,
    this.showAxisLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightDiaries = ref.watch(allWeightEntriesStreamProvider(userId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40.0),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Weight Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      if (onTap != null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: height - (showTitle ? 60 : 24),
                  child: weightDiaries.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.monitor_weight_outlined,
                                  size: 32,
                                  color: Colors.orange[400],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No weight entries yet',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to add your first entry',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Normalize to kg for plotting
                      final normalized = entries
                          .map((e) => (
                                time: e.createdAt,
                                valueKg: e.convertWeight('kg'),
                                originalWeight: e.weight,
                                originalUnit: e.unit,
                              ))
                          .toList()
                        ..sort((a, b) => a.time.compareTo(b.time));

                      final from = normalized.first.time;
                      final now = normalized.last.time;

                      return Column(
                        children: [
                          Expanded(
                            child: _WeightChart(
                              from: from,
                              to: now,
                              points: normalized,
                              color: Colors.orange[600]!,
                              originalUnit: entries.isNotEmpty ? entries.first.unit : 'kg',
                              showAxisLabels: showAxisLabels,
                            ),
                          ),
                          if (showAxisLabels) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: Text(
                                    _formatTick(from),
                                    style: TextStyle(
                                      color: Colors.grey[700], 
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: Text(
                                    _formatTick(now),
                                    style: TextStyle(
                                      color: Colors.grey[700], 
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loading weight data...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 28,
                              color: Colors.red[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load graph',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.red[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Please try again',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTick(DateTime dt) {
    final d = '${dt.month}/${dt.day}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$d $h:$m $ap';
  }
}

class _WeightChart extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final List<({DateTime time, double valueKg, double originalWeight, String originalUnit})> points;
  final Color color;
  final String originalUnit;
  final bool showAxisLabels;

  const _WeightChart({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
    required this.showAxisLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightChartPainter(
        from: from,
        to: to,
        points: points,
        color: color,
        originalUnit: originalUnit,
        showAxisLabels: showAxisLabels,
      ),
      child: Container(),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final DateTime from;
  final DateTime to;
  final List<({DateTime time, double valueKg, double originalWeight, String originalUnit})> points;
  final Color color;
  final String originalUnit;
  final bool showAxisLabels;

  _WeightChartPainter({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
    required this.showAxisLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.5;
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Adjust padding based on whether axis labels are shown
    final paddingLeft = showAxisLabels ? 50.0 : 8.0;
    final paddingRight = 8.0;
    final paddingTop = 8.0;
    final paddingBottom = 8.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final origin = Offset(paddingLeft, paddingTop);

    // Draw background grid
    _drawGrid(canvas, size, origin, chartWidth, chartHeight);

    // Axes
    canvas.drawLine(
      Offset(origin.dx, origin.dy + chartHeight),
      Offset(origin.dx + chartWidth, origin.dy + chartHeight),
      paintAxis,
    );

    // Y-axis
    canvas.drawLine(
      Offset(origin.dx, origin.dy),
      Offset(origin.dx, origin.dy + chartHeight),
      paintAxis,
    );

    if (points.isEmpty) return;

    // Y-range with padding, ensuring minY never goes below 0 for weight
    double minY = points.map((e) => e.valueKg).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((e) => e.valueKg).reduce((a, b) => a > b ? a : b);
    
    if (minY == maxY) {
      minY = (minY - 0.5).clamp(0.0, double.infinity);
      maxY += 0.5;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY = (minY - pad).clamp(0.0, double.infinity); // Ensure minY >= 0
      maxY += pad;
    }
    
    // If all weights are very close to 0, ensure we have a reasonable range
    if (maxY < 5.0) {
      maxY = 5.0;
    }

    // Draw Y-axis labels only if enabled
    if (showAxisLabels) {
      _drawYAxisLabels(canvas, size, minY, maxY, origin, chartHeight);
    }

    final totalMs = to.millisecondsSinceEpoch - from.millisecondsSinceEpoch;
    Offset mapPoint(DateTime t, double v) {
      final xRatio = ((t.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / totalMs).clamp(0.0, 1.0);
      final yRatio = ((v - minY) / (maxY - minY)).clamp(0.0, 1.0);
      final x = origin.dx + xRatio * chartWidth;
      final y = origin.dy + chartHeight - yRatio * chartHeight;
      return Offset(x, y);
    }

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = mapPoint(points[i].time, points[i].valueKg);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    // Fill under line with gradient
    final fillPath = Path.from(path)
      ..lineTo(origin.dx + chartWidth, origin.dy + chartHeight)
      ..lineTo(origin.dx, origin.dy + chartHeight)
      ..close();
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Points with gradient effect
    for (final pt in points) {
      final o = mapPoint(pt.time, pt.valueKg);
      
      // Outer circle
      final outerPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(o, 6, outerPaint);
      
      // Inner circle
      final innerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(o, 4, innerPaint);
      
      // Center dot
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(o, 2, centerPaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Offset origin, double chartWidth, double chartHeight) {
    final gridPaint = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = origin.dy + (i * chartHeight / 5);
      canvas.drawLine(
        Offset(origin.dx, y),
        Offset(origin.dx + chartWidth, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 1; i < 5; i++) {
      final x = origin.dx + (i * chartWidth / 5);
      canvas.drawLine(
        Offset(x, origin.dy),
        Offset(x, origin.dy + chartHeight),
        gridPaint,
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double minY, double maxY, Offset origin, double chartHeight) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Number of Y-axis labels
    const int numLabels = 5;
    final step = (maxY - minY) / (numLabels - 1);

    for (int i = 0; i < numLabels; i++) {
      final value = minY + (step * i);
      final displayValue = originalUnit == 'kg' ? value : value * 2.20462; // Convert back if needed
      final labelText = originalUnit == 'kg' 
          ? '${displayValue.toStringAsFixed(1)} kg'
          : '${displayValue.toStringAsFixed(1)} lbs';

      textPainter
        ..text = TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        )
        ..layout();

      final yPos = origin.dy + chartHeight - (i * chartHeight / (numLabels - 1));

      // Draw label with background
      final labelRect = Rect.fromLTWH(
        origin.dx - textPainter.width - 8,
        yPos - textPainter.height / 2 - 2,
        textPainter.width + 4,
        textPainter.height + 4,
      );
      
      final labelBgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        labelBgPaint,
      );

      textPainter.paint(
        canvas, 
        Offset(origin.dx - textPainter.width - 6, yPos - textPainter.height / 2)
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.points != points || 
           oldDelegate.color != color || 
           oldDelegate.from != from || 
           oldDelegate.to != to ||
           oldDelegate.originalUnit != originalUnit ||
           oldDelegate.showAxisLabels != showAxisLabels;
  }
}