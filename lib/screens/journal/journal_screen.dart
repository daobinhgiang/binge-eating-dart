import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/money_diary_provider.dart';
import '../../widgets/weight_graph_widget.dart';
import '../../core/services/reset_timer_service.dart';
import 'food_diary_main_screen.dart';
import 'body_image_diary_main_screen.dart';
import 'weight_diary_survey_screen.dart';
import 'money_diary_main_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  final GlobalKey? weightDiaryKey;
  
  const JournalScreen({super.key, this.weightDiaryKey});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  // Timer state
  DateTime? _lastResetTime;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadLastResetTime();
    _startTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastResetTime() async {
    final lastReset = await ResetTimerService().getLastResetTime();
    if (mounted) {
      setState(() {
        _lastResetTime = lastReset;
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
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  'Journal',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
              ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 24),
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Binge-Free Timer Widget
                    _buildBingeFreeTimer(),
                    
                    const SizedBox(height: 24),
                    
                    // Weight Progress Graph and Spending Diary Row
                    _buildTopRowCards(context, user.id),
                    
                    const SizedBox(height: 24),
                    
                    // Diary Access Cards
                    _buildDiaryAccessCards(context),
                    
                    const SizedBox(height: 100), // Extra space for floating action button
                  ]),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJournalOptions(context),
        backgroundColor: const Color(0xFF4CAF50), // Green color
        foregroundColor: Colors.white,
        elevation: 8,
        mini: false,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProgressStat(String label, String current, String total) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$total',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRowCards(BuildContext context, String userId) {
    // Calculate the available width and create square buttons
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 40.0; // 20px padding on each side
    final spacing = 16.0; // Space between buttons
    final availableWidth = screenWidth - padding;
    final buttonWidth = (availableWidth - spacing) / 2;
    final buttonSize = buttonWidth; // Make it square
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Weight Graph Widget
        SizedBox(
          key: widget.weightDiaryKey,
          width: buttonSize,
          height: buttonSize,
          child: WeightGraphWidget(
            userId: userId,
            onTap: () => _navigateToWeightDiarySurvey(context),
            height: buttonSize,
            showTitle: true,
            showAxisLabels: false,
          ),
        ),
        // Spending Diary Card
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: _buildSpendingDiaryCard(context, userId, height: buttonSize),
        ),
      ],
    );
  }

  Widget _buildDiaryAccessCards(BuildContext context) {
    // Calculate the available width and create square buttons
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 40.0; // 20px padding on each side
    final spacing = 16.0; // Space between buttons
    final availableWidth = screenWidth - padding;
    final buttonWidth = (availableWidth - spacing) / 2;
    final buttonSize = buttonWidth; // Make it square
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Food Diary Card
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: _buildDiaryCard(
            context,
            title: 'Food Diary',
            subtitle: 'Track your meals',
            icon: Icons.restaurant,
            color: const Color(0xFF4CAF50),
            onTap: () => _navigateToFoodDiarySurvey(context),
          ),
        ),
        // Body Image Diary Card
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: _buildDiaryCard(
            context,
            title: 'Body Image',
            subtitle: 'Track body checking',
            icon: Icons.visibility,
            color: Colors.teal[600]!,
            onTap: () => _navigateToBodyImageDiarySurvey(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on button size
        final buttonHeight = constraints.maxHeight;
        final textContainerHeight = buttonHeight / 4;
        final fontSize = textContainerHeight * 0.35; // Scale font to ~35% of container height
        
        return Container(
          // Remove fixed height to make it responsive to parent container
          decoration: BoxDecoration(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(40.0),
                child: Column(
                  children: [
                    // Top image section - takes up remaining space
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_getJournalImage(title)),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    // Bottom white overlay section - exactly 1/4 of button height
                    Container(
                      width: double.infinity,
                      height: textContainerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: textContainerHeight * 0.15,
                        vertical: textContainerHeight * 0.12,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  String _getJournalImage(String title) {
    if (title.toLowerCase().contains('food')) {
      return 'assets/journal/food_diary.png';
    } else if (title.toLowerCase().contains('body')) {
      return 'assets/journal/body_image2.png';
    } else if (title.toLowerCase().contains('spending') || title.toLowerCase().contains('money')) {
      return 'assets/journal/spending_diary2.png';
    }
    return 'assets/journal/food_diary.png'; // Default fallback
  }

  Widget _buildSpendingDiaryCard(BuildContext context, String userId, {double height = 280}) {
    final totalSpent = ref.watch(totalSpentProvider(userId));

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on button size
        final buttonHeight = constraints.maxHeight;
        final textContainerHeight = buttonHeight / 4;
        final fontSize = textContainerHeight * 0.35; // Scale font to ~35% of container height
        final amountFontSize = buttonHeight * 0.15; // Amount is ~15% of button height
        
        return Container(
          // Remove fixed height to make it responsive to parent container
          decoration: BoxDecoration(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToMoneyDiary(context),
                borderRadius: BorderRadius.circular(40.0),
                child: Column(
                  children: [
                    // Top section - shows only dollar amount
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber[100]!,
                              Colors.amber[50]!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: totalSpent.when(
                            data: (total) => FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: buttonHeight * 0.08),
                                child: Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: GoogleFonts.fredoka(
                                    fontSize: amountFontSize,
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            loading: () => SizedBox(
                              height: amountFontSize * 0.8,
                              width: amountFontSize * 0.8,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            ),
                            error: (error, _) => FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: buttonHeight * 0.08),
                                child: Text(
                                  '\$0.00',
                                  style: GoogleFonts.fredoka(
                                    fontSize: amountFontSize,
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom white overlay section - exactly 1/4 of button height
                    Container(
                      width: double.infinity,
                      height: textContainerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: textContainerHeight * 0.15,
                        vertical: textContainerHeight * 0.12,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Spending Diary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  void _showAddJournalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 1,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Text(
                      'Add New Journal Entry',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAddOption(
                      context,
                      'Food Diary',
                      'Log your meals and eating behaviors',
                      Icons.restaurant,
                      const Color(0xFF4CAF50),
                      () => _navigateToFoodDiarySurvey(context),
                    ),
                    const SizedBox(height: 16),
                    _buildAddOption(
                      context,
                      'Weight Diary',
                      'Track your weight and progress',
                      Icons.monitor_weight,
                      Colors.orange[600]!,
                      () => _navigateToWeightDiarySurvey(context),
                    ),
                    const SizedBox(height: 16),
                    _buildAddOption(
                      context,
                      'Body Image Diary',
                      'Track body checking behaviors',
                      Icons.visibility,
                      Colors.teal[600]!,
                      () => _navigateToBodyImageDiarySurvey(context),
                    ),
                    const SizedBox(height: 16),
                    _buildAddOption(
                      context,
                      'Spending Diary',
                      'Track spending on binge eating',
                      Icons.account_balance_wallet,
                      Colors.amber[600]!,
                      () => _navigateToMoneyDiary(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFoodDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodDiaryMainScreen(),
      ),
    );
  }

  void _navigateToWeightDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeightDiarySurveyScreen(),
      ),
    );
  }

  void _navigateToBodyImageDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BodyImageDiaryMainScreen(),
      ),
    );
  }

  void _navigateToMoneyDiary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MoneyDiaryMainScreen(),
      ),
    );
  }

  // Binge-Free Timer Widget Methods
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
                backgroundColor: isFirstTime ? const Color(0xFF4CAF50) : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(isFirstTime ? 'Start' : 'Reset'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

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
              content: Text(isFirstTime ? 'Timer started! Good luck on your journey!' : 'Reset time logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        Navigator.of(context).pop();
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

  Widget _buildBingeFreeTimer() {
    if (_lastResetTime == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
              icon: const Icon(Icons.play_arrow, size: 24),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
      padding: const EdgeInsets.all(24),
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
  
  Widget _buildIOSTimerLayout(List<Map<String, dynamic>> timeUnits, int days, int hours, int minutes, int seconds) {
    return Column(
      children: [
        // Circular progress rings
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            size: const Size(280, 280),
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
          style: GoogleFonts.fredoka(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Time units displayed in a row below the circle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: timeUnits.map((unit) {
            final fontSize = 28.0;
            final labelSize = 14.0;
            
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  const SizedBox(height: 2),
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
    _drawRing(canvas, center, daysRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, hoursRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, minutesRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, secondsRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    
    // Progress rings with glow
    _drawRing(canvas, center, daysRadius, strokeWidth, daysColor, daysProgress, true);
    _drawRing(canvas, center, hoursRadius, strokeWidth, hoursColor, hoursProgress, true);
    _drawRing(canvas, center, minutesRadius, strokeWidth, minutesColor, minutesProgress, true);
    _drawRing(canvas, center, secondsRadius, strokeWidth, secondsColor, secondsProgress, true);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeWidth, Color color, double progress, bool addGlow) {
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
