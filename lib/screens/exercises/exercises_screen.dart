import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  // Custom color for Problem Solving
  static const MaterialColor _problemSolvingColor = MaterialColor(
    0xFFfa5420,
    <int, Color>{
      50: Color(0xFFFFEDE8),
      100: Color(0xFFFFD2C5),
      200: Color(0xFFFFB49E),
      300: Color(0xFFFF9577),
      400: Color(0xFFFF7E5A),
      500: Color(0xFFFF663D),
      600: Color(0xFFfa5420),
      700: Color(0xFFEF4D1B),
      800: Color(0xFFE44316),
      900: Color(0xFFD6320D),
    },
  );

  // Exercise data
  static final List<ExerciseItem> exercises = [
    ExerciseItem(
      title: 'Problem Solving',
      description: 'Structured approach to solving challenges',
      icon: Icons.psychology,
      color: _problemSolvingColor,
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
      color: Colors.teal,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const UrgeSurfingScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Addressing Overconcern',
      description: 'Work through excessive concerns about weight and shape',
      icon: Icons.balance,
      color: Colors.orange,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddressingOverconcernScreen()),
      ),
    ),
    ExerciseItem(
      title: 'Addressing Setbacks',
      description: 'Navigate and learn from recovery setbacks',
      icon: Icons.trending_up,
      color: Colors.purple,
      onTap: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddressingSetbacksScreen()),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Exercises',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ...exercises.map((exercise) => _buildExerciseCard(context, exercise)),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ),
          ],
          ),
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
                    borderRadius: BorderRadius.circular(40.0),
                    boxShadow: isHovered ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                        spreadRadius: 2,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ] : [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                        borderRadius: BorderRadius.circular(40.0),
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
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: exercise.color[600],
                                        borderRadius: BorderRadius.circular(40.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: exercise.color[600]!.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(40.0),
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
      return 'assets/exercises/problem_solving2.png';
    }
    if (key.contains('meal') && key.contains('planning')) {
      return 'assets/exercises/meal_planning.png';
    }
    if (key.contains('urge') && (key.contains('surfing') || key.contains('activities')) ) {
      return 'assets/exercises/urge_surfing2.png';
    }
    if (key.contains('overconcern')) {
      return 'assets/exercises/addressing_overconcern2.png';
    }
    if (key.contains('setbacks')) {
      return 'assets/exercises/addressing_setbacks2.png';
    }
    return 'assets/exercises/problem_solving2.png';
  }

}