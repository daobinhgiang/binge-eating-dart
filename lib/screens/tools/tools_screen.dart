import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'problem_solving_main_screen.dart';
import 'meal_planning_screen.dart';
import 'urge_surfing_screen.dart';
import 'addressing_overconcern_screen.dart';
import 'addressing_setbacks_screen.dart';

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
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...exercises.map((exercise) => _buildExerciseCard(context, exercise)).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildHeaderContent(context);
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ) ??
                const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[300],
        ),
      ],
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
                    borderRadius: BorderRadius.circular(16),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => exercise.onTap(context),
                        child: Column(
                          children: [
                            // Top photo section
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(_assetForExercise(exercise.title)),
                                    fit: BoxFit.cover,
                                    colorFilter: isHovered
                                        ? ColorFilter.mode(Colors.black.withOpacity(0.05), BlendMode.darken)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            // Bottom white overlay section - sized to content
                            Container(
                              width: double.infinity,
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
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    exercise.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    exercise.description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[700],
                                          height: 1.3,
                                        ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () => exercise.onTap(context),
                                          child: Center(
                                            child: Text(
                                              'Start Exercise',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  String _assetForExercise(String title) {
    final key = title.toLowerCase();
    if (key.contains('problem') && key.contains('solving')) {
      return 'assets/exercises/problem_solving.png';
    }
    if (key.contains('meal') && key.contains('planning')) {
      return 'assets/exercises/meal_planning.png';
    }
    if (key.contains('urge') && (key.contains('surfing') || key.contains('activities')) ) {
      return 'assets/exercises/urge_surfing.png';
    }
    if (key.contains('overconcern')) {
      return 'assets/exercises/addressing_overconcern.png';
    }
    if (key.contains('setbacks')) {
      return 'assets/exercises/addressing_setbacks.png';
    }
    return 'assets/exercises/problem_solving.png';
  }

  int _getActivityCount(String title) {
    final key = title.toLowerCase();
    if (key.contains('problem') && key.contains('solving')) {
      return 5; // Problem solving steps
    }
    if (key.contains('meal') && key.contains('planning')) {
      return 4; // Meal planning activities
    }
    if (key.contains('urge') && (key.contains('surfing') || key.contains('activities'))) {
      return 6; // Urge surfing techniques
    }
    if (key.contains('overconcern')) {
      return 3; // Overconcern exercises
    }
    if (key.contains('setbacks')) {
      return 4; // Setback recovery steps
    }
    return 3; // Default count
  }
}