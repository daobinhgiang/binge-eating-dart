import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/weight_diary.dart';
import '../../providers/weight_diary_provider.dart';

class WeightDiarySurveyScreen extends ConsumerStatefulWidget {
  const WeightDiarySurveyScreen({super.key});

  @override
  ConsumerState<WeightDiarySurveyScreen> createState() => _WeightDiarySurveyScreenState();
}

class _WeightDiarySurveyScreenState extends ConsumerState<WeightDiarySurveyScreen> {
  final TextEditingController _weightController = TextEditingController();
  String _unit = WeightDiary.weightUnits.first; // default 'kg'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent(context)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Weight Diary',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-history Weight Graph
            _buildFullHistoryGraph(context),
            const SizedBox(height: 24),
            Text(
              'Log your current weight',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your weight and select the unit. This will be saved with the current time.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: 'e.g., 68.5',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    items: WeightDiary.weightUnits.map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase()))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unit = v);
                    },
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullHistoryGraph(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }

    final allAsync = ref.watch(allWeightEntriesStreamProvider(user.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight over time',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.timeline, size: 18, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: allAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No weight entries yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 180,
                    child: _WeightChart(
                      from: from,
                      to: now,
                      points: normalized,
                      color: Colors.orange[700]!,
                      originalUnit: entries.isNotEmpty ? entries.first.unit : 'kg',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTick(from),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        _formatTick(now),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => SizedBox(
              height: 180,
              child: Center(
                child: Text('Failed to load graph: $error', style: TextStyle(color: Colors.red[600])),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTick(DateTime dt) {
    final d = '${dt.month}/${dt.day}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$d $h:$m $ap';
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : const Text('Save Weight', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
      ),
    );
  }

  bool _validate() {
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter your weight.');
      return false;
    }
    final value = double.tryParse(text);
    if (value == null || value <= 0) {
      _showError('Please enter a valid positive number.');
      return false;
    }
    if (value > 635) { // heavier than world record, likely an error
      _showError('That value seems too high. Please check and try again.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final weight = double.parse(_weightController.text.trim());
      final entry = await ref.read(currentWeekWeightDiariesProvider(user.id).notifier).createEntry(
        weight: weight,
        unit: _unit,
      );

      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight saved successfully!'), backgroundColor: Colors.green),
        );
        // Clear the form after successful submission
        _weightController.clear();
        // Don't navigate away - let user stay on the weight diary page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving weight: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _WeightChart extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final List<({DateTime time, double valueKg, double originalWeight, String originalUnit})> points;
  final Color color;
  final String originalUnit;

  const _WeightChart({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
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

  _WeightChartPainter({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
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

    final paddingLeft = 45.0; // Increased for Y-axis labels
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

    // Draw Y-axis labels
    _drawYAxisLabels(canvas, size, minY, maxY, origin, chartHeight);

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
            fontSize: 10,
          ),
        )
        ..layout();

      final yPos = origin.dy + chartHeight - (i * chartHeight / (numLabels - 1));
      
      // Draw horizontal grid line
      final gridPaint = Paint()
        ..color = const Color(0xFFF0F0F0)
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(origin.dx, yPos),
        Offset(origin.dx + size.width - 45 - 8, yPos),
        gridPaint,
      );

      // Draw label
      textPainter.paint(
        canvas, 
        Offset(origin.dx - textPainter.width - 5, yPos - textPainter.height / 2)
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.points != points || 
           oldDelegate.color != color || 
           oldDelegate.from != from || 
           oldDelegate.to != to ||
           oldDelegate.originalUnit != originalUnit;
  }
}

