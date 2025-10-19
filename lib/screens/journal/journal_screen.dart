import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/money_diary_provider.dart';
import '../../widgets/weight_graph_widget.dart';
import 'food_diary_main_screen.dart';
import 'body_image_diary_main_screen.dart';
import 'weight_diary_survey_screen.dart';
import 'money_diary_main_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {

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
                        alignment: Alignment.centerLeft,
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
                        alignment: Alignment.centerLeft,
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





}
