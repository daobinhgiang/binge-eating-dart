import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/reset_timer_service.dart';
import 'tree_growth_widget.dart';

class BingeFreeTimerCarouselWidget extends ConsumerStatefulWidget {
  const BingeFreeTimerCarouselWidget({super.key});

  @override
  ConsumerState<BingeFreeTimerCarouselWidget> createState() =>
      _BingeFreeTimerCarouselWidgetState();
}

class _BingeFreeTimerCarouselWidgetState
    extends ConsumerState<BingeFreeTimerCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  DateTime? _lastResetTime;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75, // Show more of adjacent pages
    );
    _loadLastResetTime();
    _startTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastResetTime() async {
    final lastReset = await ResetTimerService().getLastResetTime();
    if (mounted) {
      setState(() {
        _lastResetTime = lastReset;
        // If timer is active, start on timer page; else start on tree page
        if (lastReset != null && _currentPage == 0) {
          _pageController.jumpToPage(1);
          _currentPage = 1;
        }
      });
    }
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild every second to update the timer display
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView carousel
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 2,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  }
                  
                  final scale = Curves.easeInOut.transform(value);
                  
                  return Center(
                    child: ClipRect(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: index == 0
                    ? const TreeGrowthWidget()
                    : _buildBingeFreeTimer(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Navigation buttons and dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrow
            if (_currentPage > 0)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: const Color(0xFF4CAF50),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 48), // Placeholder for alignment when arrow not visible
            
            const SizedBox(width: 16),
            
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 10 : 8,
                    height: _currentPage == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(width: 16),
            
            // Right arrow
            if (_currentPage < 1)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  color: const Color(0xFF4CAF50),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 48), // Placeholder for alignment when arrow not visible
          ],
        ),
      ],
    );
  }

  Widget _buildBingeFreeTimer() {
    if (_lastResetTime == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Start tracking your binge-free progress',
              style: GoogleFonts.fredoka(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleResetButton,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(
                'Start Timer',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    final duration = DateTime.now().difference(_lastResetTime!);

    // Calculate time units
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    // Build list of all non-zero time units to display
    List<Map<String, dynamic>> timeUnits = [];

    // Determine font size based on how many units we'll show
    double fontSize;
    if (days > 0) {
      fontSize = 36.0; // 4 units: days, hours, minutes, seconds
    } else if (hours > 0) {
      fontSize = 42.0; // 3 units: hours, minutes, seconds
    } else if (minutes > 0) {
      fontSize = 48.0; // 2 units: minutes, seconds
    } else {
      fontSize = 72.0; // 1 unit: seconds only
    }

    if (days > 0) {
      timeUnits.add({
        'value': days.toString().padLeft(2, '0'),
        'label': days == 1 ? 'day' : 'days',
        'size': fontSize,
      });
    }
    if (hours > 0 || days > 0) {
      timeUnits.add({
        'value': hours.toString().padLeft(2, '0'),
        'label': 'hrs',
        'size': fontSize,
      });
    }
    if (minutes > 0 || hours > 0 || days > 0) {
      timeUnits.add({
        'value': minutes.toString().padLeft(2, '0'),
        'label': 'min',
        'size': fontSize,
      });
    }
    // Always show seconds
    timeUnits.add({
      'value': seconds.toString().padLeft(2, '0'),
      'label': 'sec',
      'size': fontSize,
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress indicator
          _buildIOSTimerLayout(timeUnits, days, hours, minutes, seconds),
          const SizedBox(height: 16),
          // Reset Timer button
          ElevatedButton.icon(
            onPressed: _handleResetButton,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              'Reset Timer',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSTimerLayout(List<Map<String, dynamic>> timeUnits, int days,
      int hours, int minutes, int seconds) {
    return Column(
      children: [
        // Circular progress rings - larger size
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            size: const Size(220, 220),
            painter: CircularTimerPainter(
              days: days,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Text above the time units
        Text(
          "You've been binge-free for:",
          style: GoogleFonts.fredoka(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Time units displayed in a row below the circle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: timeUnits.map((unit) {
            final fontSize = 18.0;
            final labelSize = 10.0;

            // Determine color based on the time unit type
            Color unitColor;
            final label = unit['label'] as String;
            if (label.contains('day')) {
              unitColor = const Color(0xFF4CAF50); // Green for days
            } else if (label.contains('hrs')) {
              unitColor = const Color(0xFF9C27B0); // Purple for hours
            } else if (label.contains('min')) {
              unitColor = const Color(0xFFFF9800); // Orange for minutes
            } else {
              unitColor = const Color(0xFF2196F3); // Blue for seconds
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    unit['value'] as String,
                    style: GoogleFonts.fredoka(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: unitColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    unit['label'] as String,
                    style: GoogleFonts.fredoka(
                      fontSize: labelSize,
                      color: unitColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _handleResetButton() async {
    try {
      final isFirstTime = _lastResetTime == null;

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isFirstTime ? Icons.play_arrow : Icons.refresh,
                color: isFirstTime ? const Color(0xFF4CAF50) : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(isFirstTime ? 'Start Timer' : 'Reset Timer'),
            ],
          ),
          content: Text(
            isFirstTime
                ? 'Ready to start tracking your binge-free progress?'
                : 'Are you sure you want to reset your timer? This will log a new reset time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFirstTime ? const Color(0xFF4CAF50) : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(isFirstTime ? 'Start' : 'Reset'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Log the reset time
        await ResetTimerService().logResetTime();

        // Reload the last reset time
        await _loadLastResetTime();

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFirstTime
                  ? 'Timer started! Good luck on your journey!'
                  : 'Reset time logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log reset time: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Custom painter for circular timer rings
class CircularTimerPainter extends CustomPainter {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  CircularTimerPainter({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 16.0;

    // Calculate progress values (normalized to 0-1)
    // Seconds: Progress through current minute (resets every 60 seconds)
    final secondsProgress = (seconds / 60).clamp(0.0, 1.0);

    // Minutes: Progress through current hour (resets every 60 minutes)
    final minutesProgress = (minutes / 60).clamp(0.0, 1.0);

    // Hours: Progress through current day (resets every 24 hours)
    final hoursProgress = (hours / 24).clamp(0.0, 1.0);

    // Days: Progress through current month (resets every 30 days)
    final daysProgress = (days % 30 / 30).clamp(0.0, 1.0);

    // Define ring radii (from outer to inner)
    final daysRadius = size.width / 2 - strokeWidth / 2;
    final hoursRadius = daysRadius - strokeWidth - 8;
    final minutesRadius = hoursRadius - strokeWidth - 8;
    final secondsRadius = minutesRadius - strokeWidth - 8;

    // App-themed colors for better visual variety
    final daysColor = const Color(0xFF4CAF50); // Light Green (matches app theme)
    final hoursColor = const Color(0xFF9C27B0); // Purple
    final minutesColor = const Color(0xFFFF9800); // Orange
    final secondsColor = const Color(0xFF2196F3); // Blue

    // Background rings (light gray)
    _drawRing(canvas, center, daysRadius, strokeWidth, Colors.grey[200]!, 1.0,
        false);
    _drawRing(canvas, center, hoursRadius, strokeWidth, Colors.grey[200]!, 1.0,
        false);
    _drawRing(canvas, center, minutesRadius, strokeWidth, Colors.grey[200]!,
        1.0, false);
    _drawRing(canvas, center, secondsRadius, strokeWidth, Colors.grey[200]!,
        1.0, false);

    // Progress rings with glow
    _drawRing(canvas, center, daysRadius, strokeWidth, daysColor, daysProgress,
        true);
    _drawRing(canvas, center, hoursRadius, strokeWidth, hoursColor,
        hoursProgress, true);
    _drawRing(canvas, center, minutesRadius, strokeWidth, minutesColor,
        minutesProgress, true);
    _drawRing(canvas, center, secondsRadius, strokeWidth, secondsColor,
        secondsProgress, true);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeWidth,
      Color color, double progress, bool addGlow) {
    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw effects for progress rings
    if (addGlow && progress > 0) {
      // Outer shadow (drop shadow)
      final outerShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(rect, startAngle, sweepAngle, false, outerShadowPaint);

      // Outer glow (reduced by 2/3)
      final glowPaint1 = Paint()
        ..color = color.withOpacity(0.13) // 0.4 * 1/3 ≈ 0.13
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2 // 6 * 1/3 = 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.7); // 5 * 1/3 ≈ 1.7

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint1);

      // Inner glow (reduced by 2/3)
      final glowPaint2 = Paint()
        ..color = color.withOpacity(0.2) // 0.6 * 1/3 = 0.2
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 1 // 3 * 1/3 = 1
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7); // 2 * 1/3 ≈ 0.7

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint2);

      // Outer stroke (border)
      final outerStrokePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, outerStrokePaint);
    }

    // Main ring
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.hours != hours ||
        oldDelegate.minutes != minutes ||
        oldDelegate.seconds != seconds;
  }
}
