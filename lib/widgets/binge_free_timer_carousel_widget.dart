import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/reset_timer_service.dart';
import 'tree_growth_widget.dart';

class BingeFreeTimerCarouselWidget extends ConsumerStatefulWidget {
  final GlobalKey? treeWidgetKey;
  final GlobalKey<BingeFreeTimerCarouselWidgetState>? carouselKey;
  
  const BingeFreeTimerCarouselWidget({
    super.key, 
    this.treeWidgetKey,
    this.carouselKey,
  });

  @override
  ConsumerState<BingeFreeTimerCarouselWidget> createState() =>
      BingeFreeTimerCarouselWidgetState();
}

class BingeFreeTimerCarouselWidgetState
    extends ConsumerState<BingeFreeTimerCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  DateTime? _lastResetTime;
  Timer? _updateTimer;
  final GlobalKey _timerButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75, // Show more of adjacent pages
      initialPage: 0, // Always start on the plant page (index 0)
    );
    _loadLastResetTime();
    _startTimer();
    print('🎯 Carousel: Widget initialized');
  }

  @override
  void dispose() {
    print('🎯 Carousel: DISPOSING');
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

  // Public method to navigate to a specific page (for tutorial use)
  void navigateToPage(int pageIndex) {
    print('🎯 navigateToPage method called with index: $pageIndex');
    print('🎯 Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
    print('🎯 Widget mounted: $mounted');
    print('🎯 PageController hasClients: ${_pageController.hasClients}');
    
    if (!mounted) {
      print('❌ Widget not mounted');
      return;
    }
    
    if (!_pageController.hasClients) {
      print('❌ PageController has no clients, trying to attach...');
      // Wait longer on web for the PageView to attach to the controller
      final delay = kIsWeb ? const Duration(milliseconds: 300) : const Duration(milliseconds: 100);
      Future.delayed(delay, () {
        if (mounted && _pageController.hasClients) {
          print('✅ PageController now has clients, retrying navigation');
          navigateToPage(pageIndex);
        } else {
          print('❌ Still no clients after delay');
        }
      });
      return;
    }
    
    try {
      print('🎯 Current page: ${_pageController.page}');
      print('🎯 Position has dimensions: ${_pageController.position.haveDimensions}');
      print('🎯 Animating to page $pageIndex');
      
      // On web, use jumpToPage first, then animate for smoother transition
      if (kIsWeb) {
        print('🌐 Using web-specific navigation');
        // First jump to the page immediately
        _pageController.jumpToPage(pageIndex);
        setState(() {
          _currentPage = pageIndex;
        });
        print('✅ Jumped to page $pageIndex');
      } else {
        // On mobile, use the normal animation
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ).then((_) {
          print('✅ Animation completed');
          setState(() {
            _currentPage = pageIndex;
          });
        }).catchError((error) {
          print('❌ Animation error: $error');
        });
      }
    } catch (e) {
      print('❌ Exception during navigation: $e');
    }
  }

  // Expose the timer button key for tutorials
  GlobalKey get timerButtonKey => _timerButtonKey;

  // Expose whether timer has been started
  bool get hasStartedTimer => _lastResetTime != null;

  // Public method to trigger timer button (for tutorial use)
  void triggerTimerButton() {
    print('🎯 triggerTimerButton called from tutorial');
    _handleResetButton();
  }

  @override
  Widget build(BuildContext context) {
    // Register this widget instance with the key for external access
    if (widget.carouselKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.carouselKey!.currentState == null) {
          print('⚠️  Carousel key currentState is null');
        } else {
          print('✅ Carousel key currentState is available');
        }
      });
    }
    
    return Column(
      children: [
        // PageView carousel
        SizedBox(
          height: 480, // Increased height to accommodate shadows (400 + 80 for top/bottom shadows)
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30), // Increased vertical padding for shadows
            child: GestureDetector(
              onPanUpdate: (details) {
                // Handle mouse drag for web compatibility
                if (details.delta.dx.abs() > details.delta.dy.abs()) {
                  // Horizontal drag detected
                  final sensitivity = 0.5;
                  final offset = details.delta.dx * sensitivity;
                  _pageController.position.moveTo(_pageController.position.pixels - offset);
                }
              },
              onPanEnd: (details) {
                // Snap to nearest page after drag ends
                final velocity = details.velocity.pixelsPerSecond.dx;
                if (velocity.abs() > 500) {
                  // Fast swipe - go to next/previous page
                  if (velocity > 0 && _currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else if (velocity < 0 && _currentPage < 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Snap back to current page
                    _pageController.animateToPage(
                      _currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else {
                  // Slow drag - snap to nearest page
                  final currentOffset = _pageController.position.pixels;
                  final pageWidth = _pageController.position.viewportDimension;
                  final targetPage = (currentOffset / pageWidth).round();
                  _pageController.animateToPage(
                    targetPage.clamp(0, 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: PageView.builder(
                clipBehavior: Clip.none, // Prevent clipping of shadows
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
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: index == 0
                        ? _buildTreeContainer()
                        : _buildBingeFreeTimer(),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicators only
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
                width: 10,
                height: 10,
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
      ],
    );
  }

  Widget _buildTreeContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TreeGrowthWidget(treeImageKey: widget.treeWidgetKey),
    );
  }

  Widget _buildBingeFreeTimer() {
    if (_lastResetTime == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minHeight: 360),
        alignment: Alignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start tracking your binge-free progress',
              style: GoogleFonts.quicksand(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: _timerButtonKey,
              onPressed: _handleResetButton,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(
                'Start Timer',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
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
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 2),
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
            key: _timerButtonKey,
            onPressed: _handleResetButton,
            icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'Reset',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
            width: 240,
            height: 240,
            child: CustomPaint(
              size: const Size(240, 240),
            painter: CircularTimerPainter(
              days: days,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Text above the time units
        Text(
          "You've been binge-free for:",
          style: GoogleFonts.quicksand(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // Time units displayed in a row below the circle with minimal gap
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: timeUnits.map((unit) {
            final fontSize = 28.0;

            // Determine color based on the time unit type - matching the bright progress ring colors
            Color unitColor;
            final label = unit['label'] as String;
            if (label.contains('day')) {
              unitColor = const Color(0xFF00FF88); // Electric lime green for days
            } else if (label.contains('hrs')) {
              unitColor = const Color(0xFFFF1744); // Electric pink/red for hours
            } else if (label.contains('min')) {
              unitColor = const Color(0xFFFFAB00); // Electric amber for minutes
            } else {
              unitColor = const Color(0xFF00E5FF); // Electric cyan for seconds
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5), // Added space between time units
              child: RichText(
                text: TextSpan(
                  children: [
                    // Time value
                    TextSpan(
                      text: unit['value'] as String,
                      style: GoogleFonts.quicksand(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: unitColor,
                      ),
                    ),
                    // Very small space between value and unit
                    const TextSpan(text: ' '),
                    // Time unit
                    TextSpan(
                      text: unit['label'] as String,
                      style: GoogleFonts.quicksand(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: unitColor,
                      ),
                    ),
                  ],
                ),
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

      // For first time, start immediately without confirmation
      // For reset, show confirmation dialog
      bool confirmed = true;
      
      if (!isFirstTime) {
        // Show confirmation dialog only for reset
        confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text('Reset Timer'),
              ],
            ),
            content: Text(
              'Are you sure you want to reset your timer? This will log a new reset time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Reset'),
              ),
            ],
          ),
        ) ?? false;
      }

      if (confirmed) {
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

    // Bright, youthful, energetic colors that match the app's theme
    final daysColor = const Color(0xFF00FF88); // Electric lime green for days
    final hoursColor = const Color(0xFFFF1744); // Electric pink/red for hours
    final minutesColor = const Color(0xFFFFAB00); // Electric amber for minutes
    final secondsColor = const Color(0xFF00E5FF); // Electric cyan for seconds

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

    // Main ring only - no glow effects
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
