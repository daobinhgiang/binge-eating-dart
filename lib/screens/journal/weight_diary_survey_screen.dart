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
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent(context)),
              _buildFooter(context),
            ],
          ),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                'Weight Diary',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Invisible spacer to balance the back button on the left
          SizedBox(
            width: 20, // Match the icon size
            height: 20,
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
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.timeline,
                size: 18,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weight over time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: allAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.monitor_weight_outlined,
                            size: 40,
                            color: Colors.orange[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No weight entries yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log your first weight entry below',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
                    height: 200,
                    child: _WeightChart(
                      from: from,
                      to: now,
                      points: normalized,
                      color: Colors.orange[600]!,
                      originalUnit: entries.isNotEmpty ? entries.first.unit : 'kg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
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
                          borderRadius: BorderRadius.circular(8),
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
              );
            },
            loading: () => SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading weight data...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, _) => SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 32,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load graph',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please try again',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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

    final paddingLeft = 50.0; // Increased for Y-axis labels
    final paddingRight = 12.0;
    final paddingTop = 12.0;
    final paddingBottom = 20.0;

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
           oldDelegate.originalUnit != originalUnit;
  }
}

