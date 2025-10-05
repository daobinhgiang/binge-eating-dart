import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weight_diary_provider.dart';

class WeightGraphWidget extends ConsumerWidget {
  final String userId;
  final VoidCallback? onTap;
  final double height;
  final bool showTitle;

  const WeightGraphWidget({
    super.key,
    required this.userId,
    this.onTap,
    this.height = 200,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightDiaries = ref.watch(currentWeekWeightDiariesProvider(userId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weight Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.trending_up,
                        color: Colors.orange[600],
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  height: height - (showTitle ? 60 : 32),
                  child: weightDiaries.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monitor_weight_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No weight entries yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to add your first entry',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
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
                              color: Colors.orange[700]!,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTick(from),
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                              ),
                              Text(
                                _formatTick(now),
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load graph',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
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
  final List<({DateTime time, double valueKg})> points;
  final Color color;

  const _WeightChart({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightChartPainter(from: from, to: to, points: points, color: color),
      child: Container(),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final DateTime from;
  final DateTime to;
  final List<({DateTime time, double valueKg})> points;
  final Color color;

  _WeightChartPainter({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    final paintFill = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final paddingLeft = 8.0;
    final paddingRight = 8.0;
    final paddingTop = 8.0;
    final paddingBottom = 16.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final origin = Offset(paddingLeft, paddingTop);

    // Axes
    canvas.drawLine(
      Offset(origin.dx, origin.dy + chartHeight),
      Offset(origin.dx + chartWidth, origin.dy + chartHeight),
      paintAxis,
    );

    if (points.isEmpty) return;

    // Y-range with padding
    double minY = points.map((e) => e.valueKg).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((e) => e.valueKg).reduce((a, b) => a > b ? a : b);
    if (minY == maxY) {
      minY -= 0.5;
      maxY += 0.5;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY -= pad;
      maxY += pad;
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

    // Fill under line
    final fillPath = Path.from(path)
      ..lineTo(origin.dx + chartWidth, origin.dy + chartHeight)
      ..lineTo(origin.dx, origin.dy + chartHeight)
      ..close();
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      final o = mapPoint(pt.time, pt.valueKg);
      canvas.drawCircle(o, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color || oldDelegate.from != from || oldDelegate.to != to;
  }
}
