import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'problem_solving_main_screen.dart';
import 'meal_planning_screen.dart';
import 'urge_surfing_screen.dart';
import 'addressing_overconcern_screen.dart';
import 'addressing_setbacks_screen.dart';
import '../../widgets/tools_background.dart';

class ExerciseItem {
  final String title;
  final String description;
  final IconData icon;
  final MaterialColor color;
  final Function(BuildContext) onTap;

  const ExerciseItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  // Exercise data
  static final List<ExerciseItem> exercises = [
    ExerciseItem(
      title: 'Problem Solving',
      description: 'Structured approach to solving challenges',
      icon: Icons.psychology,
      color: Colors.deepOrange,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProblemSolvingMainScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Meal Planning',
      description: 'Plan and organize your meals effectively',
      icon: Icons.restaurant_menu,
      color: Colors.green,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MealPlanningScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Urge Surfing Activities',
      description: 'Learn to ride out urges and cravings',
      icon: Icons.waves,
      color: Colors.blue,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const UrgeSurfingScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Addressing Overconcern',
      description: 'Work through excessive concerns about weight and shape',
      icon: Icons.balance,
      color: Colors.teal,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddressingOverconcernScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Addressing Setbacks',
      description: 'Navigate and learn from recovery setbacks',
      icon: Icons.trending_up,
      color: Colors.cyan,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddressingSetbacksScreen()),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF66BB6A), // Brighter, more vibrant green
                    Color(0xFF4CAF50), // Material green
                    Color(0xFF43A047), // Slightly darker green
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recovery Tools',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: exercises.map((exercise) => _buildExerciseCard(context, exercise)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseItem exercise) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileSize = MediaQuery.of(context).size.width * 0.85;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          alignment: Alignment.center,
          child: StatefulBuilder(
            builder: (context, setState) {
              bool isHovered = false;
              return MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: AnimatedContainer(
                  width: tileSize,
                  height: tileSize,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isHovered ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ] : [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => exercise.onTap(context),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                exercise.icon,
                                color: const Color(0xFF4CAF50),
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              exercise.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}