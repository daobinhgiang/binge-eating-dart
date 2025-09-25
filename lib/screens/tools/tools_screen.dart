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
      appBar: AppBar(
        title: const Text('Tools'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.purple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recovery Tools',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive exercises and strategies for eating disorder recovery',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Exercise Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseCard(context, exercise);
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseItem exercise) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => exercise.onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: exercise.color[600]?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  exercise.icon,
                  color: exercise.color[600],
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: exercise.color[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        exercise.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: exercise.color[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start',
                            style: TextStyle(
                              color: exercise.color[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: exercise.color[700],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}