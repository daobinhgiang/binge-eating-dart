import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weight_diary_provider.dart';

enum WeightGraphTimeFrame {
  day,
  week,
  month,
  allTime,
}

extension WeightGraphTimeFrameExtension on WeightGraphTimeFrame {
  String get displayName {
    switch (this) {
      case WeightGraphTimeFrame.day:
        return 'Day';
      case WeightGraphTimeFrame.week:
        return 'Week';
      case WeightGraphTimeFrame.month:
        return 'Month';
      case WeightGraphTimeFrame.allTime:
        return 'All Time';
    }
  }
}

class WeightGraphWidget extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onTap;
  final double height;
  final bool showTitle;
  final bool showAxisLabels;
  final bool showTimeFrameSelector;

  const WeightGraphWidget({
    super.key,
    required this.userId,
    this.onTap,
    this.height = 200,
    this.showTitle = true,
    this.showAxisLabels = true,
    this.showTimeFrameSelector = true,
  });

  @override
  ConsumerState<WeightGraphWidget> createState() => _WeightGraphWidgetState();
}

class _WeightGraphWidgetState extends ConsumerState<WeightGraphWidget> {
  WeightGraphTimeFrame _selectedTimeFrame = WeightGraphTimeFrame.allTime;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final weightDiaries = ref.watch(allWeightEntriesStreamProvider(widget.userId));

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
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(40.0),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showTitle) ...[
                  Center(
                    child: Text(
                      'Weight',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.showTimeFrameSelector) ...[
                  _buildTimeFrameSelector(),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: weightDiaries.when(
                    data: (entries) => _buildGraphContent(entries),
                    loading: () => _buildLoadingState(),
                    error: (error, _) => _buildErrorState(error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Row(
        children: WeightGraphTimeFrame.values.map((timeFrame) {
          final isSelected = _selectedTimeFrame == timeFrame;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeFrame = timeFrame;
                  if (timeFrame == WeightGraphTimeFrame.day) {
                    _selectedDate = DateTime.now();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(36.0),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  timeFrame.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.orange[600] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayNavigation() {
    if (_selectedTimeFrame != WeightGraphTimeFrame.day) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: Icon(Icons.chevron_left, color: Colors.orange[600], size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange[50],
              shape: const CircleBorder(),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
          Flexible(
            child: Text(
              _formatDate(_selectedDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
            icon: Icon(Icons.chevron_right, color: Colors.orange[600], size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange[50],
              shape: const CircleBorder(),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphContent(List<dynamic> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monitor_weight_outlined,
                size: 24,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No weight entries yet',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Tap to add your first entry',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    // Filter entries based on selected time frame
    final filteredEntries = _filterEntriesByTimeFrame(entries);
    
    if (filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline,
                size: 24,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No entries in this time frame',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Try a different time frame',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    // Normalize to kg for plotting
    final normalized = filteredEntries
        .map<({DateTime time, double valueKg, double originalWeight, String originalUnit})>((e) => (
              time: e.createdAt,
              valueKg: e.convertWeight('kg'),
              originalWeight: e.weight,
              originalUnit: e.unit,
            ))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    final from = normalized.first.time;
    final to = normalized.last.time;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDayNavigation(),
        Expanded(
          child: _WeightChart(
            from: from,
            to: to,
            points: normalized,
            color: Colors.orange[600]!,
            originalUnit: filteredEntries.isNotEmpty ? filteredEntries.first.unit : 'kg',
            showAxisLabels: widget.showAxisLabels,
            timeFrame: _selectedTimeFrame,
          ),
        ),
        if (widget.showAxisLabels) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text(
                    _formatTick(from, _selectedTimeFrame),
                    style: TextStyle(
                      color: Colors.grey[700], 
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text(
                    _formatTick(to, _selectedTimeFrame),
                    style: TextStyle(
                      color: Colors.grey[700], 
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
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
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 20,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Failed to load graph',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Please try again',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterEntriesByTimeFrame(List<dynamic> entries) {
    switch (_selectedTimeFrame) {
      case WeightGraphTimeFrame.day:
        final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return entries.where((entry) {
          final entryTime = entry.createdAt;
          return entryTime.isAfter(startOfDay) && entryTime.isBefore(endOfDay);
        }).toList();
        
      case WeightGraphTimeFrame.week:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return entries.where((entry) {
          final entryTime = entry.createdAt;
          return entryTime.isAfter(startOfWeek) && entryTime.isBefore(endOfWeek);
        }).toList();
        
      case WeightGraphTimeFrame.month:
        final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        return entries.where((entry) {
          final entryTime = entry.createdAt;
          return entryTime.isAfter(startOfMonth) && entryTime.isBefore(endOfMonth);
        }).toList();
        
      case WeightGraphTimeFrame.allTime:
        return entries;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTick(DateTime dt, WeightGraphTimeFrame timeFrame) {
    switch (timeFrame) {
      case WeightGraphTimeFrame.day:
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final m = dt.minute.toString().padLeft(2, '0');
        final ap = dt.hour < 12 ? 'AM' : 'PM';
        return '$h:$m $ap';
      case WeightGraphTimeFrame.week:
      case WeightGraphTimeFrame.month:
        final d = '${dt.month}/${dt.day}';
        return d;
      case WeightGraphTimeFrame.allTime:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[dt.month - 1]} ${dt.year}';
    }
  }

}

class _WeightChart extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final List<({DateTime time, double valueKg, double originalWeight, String originalUnit})> points;
  final Color color;
  final String originalUnit;
  final bool showAxisLabels;
  final WeightGraphTimeFrame timeFrame;

  const _WeightChart({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
    required this.showAxisLabels,
    required this.timeFrame,
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
        timeFrame: timeFrame,
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
  final WeightGraphTimeFrame timeFrame;

  _WeightChartPainter({
    required this.from,
    required this.to,
    required this.points,
    required this.color,
    required this.originalUnit,
    required this.showAxisLabels,
    required this.timeFrame,
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
           oldDelegate.showAxisLabels != showAxisLabels ||
           oldDelegate.timeFrame != timeFrame;
  }
}