import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/main_navigation.dart';
import 'screens/education/article_detail_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/onboarding_review_screen.dart';
import 'screens/tools/problem_solving_main_screen.dart';
import 'screens/tools/meal_planning_screen.dart';
import 'screens/tools/urge_surfing_screen.dart';
import 'screens/tools/addressing_overconcern_screen.dart';
import 'screens/tools/addressing_setbacks_screen.dart';
import 'screens/todos/todos_screen.dart';
import 'screens/todos/add_todo_screen.dart';
import 'screens/profile/regular_eating_screen.dart';
import 'screens/profile/notification_settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/chat/chat_screen.dart';
// Journal imports
import 'screens/journal/food_diary_survey_screen.dart';
import 'screens/journal/weight_diary_survey_screen.dart';
import 'screens/journal/body_image_diary_survey_screen.dart';
// Assessment imports
import 'screens/assessments/assessment_2_1_screen.dart';
import 'screens/assessments/assessment_2_2_screen.dart';
import 'screens/assessments/assessment_2_3_screen.dart';
// Lesson imports
import 'screens/lessons/lesson_1_1.dart';
import 'screens/lessons/lesson_1_2.dart';
import 'screens/lessons/lesson_1_2_1.dart';
import 'screens/lessons/lesson_1_3.dart';
import 'screens/lessons/lesson_3_1.dart';
import 'screens/lessons/lesson_3_2.dart';
import 'screens/lessons/lesson_3_3.dart';
import 'screens/lessons/lesson_3_4.dart';
import 'screens/lessons/lesson_3_5.dart';
import 'screens/lessons/lesson_3_6.dart';
import 'screens/lessons/lesson_3_7.dart';
import 'screens/lessons/lesson_3_8.dart';
import 'screens/lessons/lesson_3_9.dart';
import 'screens/lessons/lesson_3_10.dart';
import 'screens/lessons/lesson_s2_0_1.dart';
import 'screens/lessons/lesson_s2_0_2.dart';
import 'screens/lessons/lesson_s2_0_3.dart';
import 'screens/lessons/lesson_s2_0_4.dart';
import 'screens/lessons/lesson_s2_0_5.dart';
import 'screens/lessons/lesson_s2_0_6.dart';
import 'screens/lessons/lesson_s2_1_1.dart';
import 'screens/lessons/lesson_s2_1_2.dart';
import 'screens/lessons/lesson_s2_1_3.dart';
import 'screens/lessons/lesson_s2_2_1.dart';
import 'screens/lessons/lesson_s2_2_2.dart';
import 'screens/lessons/lesson_s2_2_3.dart';
import 'screens/lessons/lesson_s2_2_4.dart';
import 'screens/lessons/lesson_s2_2_5.dart';
import 'screens/lessons/lesson_s2_2_5_1.dart';
import 'screens/lessons/lesson_s2_2_6.dart';
import 'screens/lessons/lesson_s2_2_7.dart';
import 'screens/lessons/lesson_s2_3_1.dart';
import 'screens/lessons/lesson_s2_3_2.dart';
import 'screens/lessons/lesson_s2_3_2_1.dart';
import 'screens/lessons/lesson_s2_3_3.dart';
import 'screens/lessons/lesson_s2_3_4.dart';
import 'screens/lessons/lesson_s2_3_5.dart';
import 'screens/lessons/lesson_s2_4_1.dart';
import 'screens/lessons/lesson_s2_4_2.dart';
import 'screens/lessons/lesson_s2_4_2_1.dart';
import 'screens/lessons/lesson_s2_4_3.dart';
import 'screens/lessons/lesson_s2_5_1.dart';
import 'screens/lessons/lesson_s2_5_2.dart';
import 'screens/lessons/lesson_s2_6_1.dart';
import 'screens/lessons/lesson_s2_6_2.dart';
import 'screens/lessons/lesson_s2_6_3.dart';
import 'screens/lessons/lesson_s2_7_1.dart';
import 'screens/lessons/lesson_s2_7_1_1.dart';
import 'screens/lessons/lesson_s2_7_2.dart';
import 'screens/lessons/lesson_s2_7_2_1.dart';
import 'screens/lessons/lesson_s2_7_3.dart';
import 'screens/lessons/lesson_s2_7_4.dart';
import 'screens/lessons/lesson_s2_7_5.dart';
import 'screens/lessons/lesson_s2_7_6.dart';
import 'screens/lessons/lesson_s2_7_7.dart';
import 'screens/lessons/lesson_s2_7_8.dart';
import 'screens/lessons/lesson_s3_0_1.dart';
import 'screens/lessons/lesson_s3_0_2.dart';
import 'screens/lessons/lesson_s3_0_2_1.dart';
import 'providers/auth_provider.dart';
import 'providers/auto_todo_provider.dart';
import 'models/user_model.dart';
import 'widgets/analytics_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Use path-based routing instead of hash-based routing
  usePathUrlStrategy();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    // Firebase might already be initialized, which is fine
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized, continuing...');
    } else if (e.toString().contains('DEVELOPER_ERROR') || 
               e.toString().contains('Phenotype.API') ||
               e.toString().contains('FlagRegistrar')) {
      // These are emulator-specific Google Play Services errors that we can ignore
      print('⚠️ Google Play Services not available on emulator, continuing with limited functionality...');
      print('Error details: $e');
    } else {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
  
  runApp(const ProviderScope(child: BEDApp()));
}

class BEDApp extends ConsumerWidget {
  const BEDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnalyticsTracker(
      child: MaterialApp.router(
        title: 'BED Support App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7fb781), // Refined green theme for growth, healing, and comfort
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF7fb781),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7fb781),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ),
      routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // This will be handled by the auth guard in each route
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGuard(child: MainNavigation()),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) => const AuthGuard(child: MainNavigation()),
        ),
        GoRoute(
          path: 'education',
          builder: (context, state) => const AuthGuard(child: MainNavigation()),
        ),
        GoRoute(
          path: 'tools',
          builder: (context, state) => const AuthGuard(child: MainNavigation()),
        ),
        GoRoute(
          path: 'journal',
          builder: (context, state) => const AuthGuard(child: MainNavigation()),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const AuthGuard(child: MainNavigation()),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/review',
      builder: (context, state) => const AuthGuard(child: OnboardingReviewScreen()),
    ),
    GoRoute(
      path: '/education/article/:id',
      builder: (context, state) {
        final articleId = state.pathParameters['id']!;
        return AuthGuard(child: ArticleDetailScreen(articleId: articleId));
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AuthGuard(
        requiredRole: UserRole.clinician,
        child: AdminScreen(),
      ),
    ),
    GoRoute(
      path: '/tools/problem-solving',
      builder: (context, state) => const AuthGuard(child: ProblemSolvingMainScreen()),
    ),
    GoRoute(
      path: '/tools/meal-planning',
      builder: (context, state) => const AuthGuard(child: MealPlanningScreen()),
    ),
    GoRoute(
      path: '/tools/urge-surfing',
      builder: (context, state) => const AuthGuard(child: UrgeSurfingScreen()),
    ),
    GoRoute(
      path: '/tools/addressing-overconcern',
      builder: (context, state) => const AuthGuard(child: AddressingOverconcernScreen()),
    ),
    GoRoute(
      path: '/tools/addressing-setbacks',
      builder: (context, state) => const AuthGuard(child: AddressingSetbacksScreen()),
    ),
    GoRoute(
      path: '/todos',
      builder: (context, state) => const AuthGuard(child: TodosScreen()),
    ),
    GoRoute(
      path: '/todos/add',
      builder: (context, state) => const AuthGuard(child: AddTodoScreen()),
    ),
    // Chatbot route removed
    GoRoute(
      path: '/profile/regular-eating',
      builder: (context, state) => const AuthGuard(child: RegularEatingScreen()),
    ),
    GoRoute(
      path: '/profile/notifications',
      builder: (context, state) => const AuthGuard(child: NotificationSettingsScreen()),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const AuthGuard(child: NotificationsScreen()),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const AuthGuard(child: ChatScreen()),
    ),
    // Journal survey routes
    GoRoute(
      path: '/journal/food-diary',
      builder: (context, state) => const AuthGuard(child: FoodDiarySurveyScreen()),
    ),
    GoRoute(
      path: '/journal/weight-diary',
      builder: (context, state) => const AuthGuard(child: WeightDiarySurveyScreen()),
    ),
    GoRoute(
      path: '/journal/body-image-diary',
      builder: (context, state) => const AuthGuard(child: BodyImageDiarySurveyScreen()),
    ),
    // Lesson routes - Stage 1
    GoRoute(
      path: '/lesson/1_1',
      builder: (context, state) => const AuthGuard(child: Lesson11Screen()),
    ),
    GoRoute(
      path: '/lesson/1_2',
      builder: (context, state) => const AuthGuard(child: Lesson12Screen()),
    ),
    GoRoute(
      path: '/lesson/1_2_1',
      builder: (context, state) => const AuthGuard(child: Lesson121Screen()),
    ),
    GoRoute(
      path: '/lesson/1_3',
      builder: (context, state) => const AuthGuard(child: Lesson13Screen()),
    ),
    GoRoute(
      path: '/lesson/2_1',
      builder: (context, state) => const AuthGuard(child: Assessment21Screen()),
    ),
    GoRoute(
      path: '/lesson/2_2',
      builder: (context, state) => const AuthGuard(child: Assessment22Screen()),
    ),
    GoRoute(
      path: '/lesson/2_3',
      builder: (context, state) => const AuthGuard(child: Assessment23Screen()),
    ),
    GoRoute(
      path: '/lesson/3_1',
      builder: (context, state) => const AuthGuard(child: Lesson31Screen()),
    ),
    GoRoute(
      path: '/lesson/3_2',
      builder: (context, state) => const AuthGuard(child: Lesson32Screen()),
    ),
    GoRoute(
      path: '/lesson/3_3',
      builder: (context, state) => const AuthGuard(child: Lesson33Screen()),
    ),
    GoRoute(
      path: '/lesson/3_4',
      builder: (context, state) => const AuthGuard(child: Lesson34Screen()),
    ),
    GoRoute(
      path: '/lesson/3_5',
      builder: (context, state) => const AuthGuard(child: Lesson35Screen()),
    ),
    GoRoute(
      path: '/lesson/3_6',
      builder: (context, state) => const AuthGuard(child: Lesson36Screen()),
    ),
    GoRoute(
      path: '/lesson/3_7',
      builder: (context, state) => const AuthGuard(child: Lesson37Screen()),
    ),
    GoRoute(
      path: '/lesson/3_8',
      builder: (context, state) => const AuthGuard(child: Lesson38Screen()),
    ),
    GoRoute(
      path: '/lesson/3_9',
      builder: (context, state) => const AuthGuard(child: Lesson39Screen()),
    ),
    GoRoute(
      path: '/lesson/3_10',
      builder: (context, state) => const AuthGuard(child: Lesson310Screen()),
    ),
    // Lesson routes - Stage 2
    GoRoute(
      path: '/lesson/s2_0_1',
      builder: (context, state) => const AuthGuard(child: LessonS201Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_0_2',
      builder: (context, state) => const AuthGuard(child: LessonS202Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_0_3',
      builder: (context, state) => const AuthGuard(child: LessonS203Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_0_4',
      builder: (context, state) => const AuthGuard(child: LessonS204Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_0_5',
      builder: (context, state) => const AuthGuard(child: LessonS205Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_0_6',
      builder: (context, state) => const AuthGuard(child: LessonS206Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_1_1',
      builder: (context, state) => const AuthGuard(child: LessonS211Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_1_2',
      builder: (context, state) => const AuthGuard(child: LessonS212Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_1_3',
      builder: (context, state) => const AuthGuard(child: LessonS213Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_1',
      builder: (context, state) => const AuthGuard(child: LessonS221Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_2',
      builder: (context, state) => const AuthGuard(child: LessonS222Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_3',
      builder: (context, state) => const AuthGuard(child: LessonS223Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_4',
      builder: (context, state) => const AuthGuard(child: LessonS224Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_5',
      builder: (context, state) => const AuthGuard(child: LessonS225Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_5_1',
      builder: (context, state) => const AuthGuard(child: LessonS2251Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_6',
      builder: (context, state) => const AuthGuard(child: LessonS226Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_2_7',
      builder: (context, state) => const AuthGuard(child: LessonS227Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_1',
      builder: (context, state) => const AuthGuard(child: LessonS231Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_2',
      builder: (context, state) => const AuthGuard(child: LessonS232Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_2_1',
      builder: (context, state) => const AuthGuard(child: LessonS2321Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_3',
      builder: (context, state) => const AuthGuard(child: LessonS233Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_4',
      builder: (context, state) => const AuthGuard(child: LessonS234Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_3_5',
      builder: (context, state) => const AuthGuard(child: LessonS235Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_4_1',
      builder: (context, state) => const AuthGuard(child: LessonS241Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_4_2',
      builder: (context, state) => const AuthGuard(child: LessonS242Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_4_2_1',
      builder: (context, state) => const AuthGuard(child: LessonS2421Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_4_3',
      builder: (context, state) => const AuthGuard(child: LessonS243Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_5_1',
      builder: (context, state) => const AuthGuard(child: LessonS251Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_5_2',
      builder: (context, state) => const AuthGuard(child: LessonS252Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_6_1',
      builder: (context, state) => const AuthGuard(child: LessonS261Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_6_2',
      builder: (context, state) => const AuthGuard(child: LessonS262Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_6_3',
      builder: (context, state) => const AuthGuard(child: LessonS263Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_1',
      builder: (context, state) => const AuthGuard(child: LessonS271Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_1_1',
      builder: (context, state) => const AuthGuard(child: LessonS2711Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_2',
      builder: (context, state) => const AuthGuard(child: LessonS272Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_2_1',
      builder: (context, state) => const AuthGuard(child: LessonS2721Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_3',
      builder: (context, state) => const AuthGuard(child: LessonS273Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_4',
      builder: (context, state) => const AuthGuard(child: LessonS274Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_5',
      builder: (context, state) => const AuthGuard(child: LessonS275Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_6',
      builder: (context, state) => const AuthGuard(child: LessonS276Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_7',
      builder: (context, state) => const AuthGuard(child: LessonS277Screen()),
    ),
    GoRoute(
      path: '/lesson/s2_7_8',
      builder: (context, state) => const AuthGuard(child: LessonS278Screen()),
    ),
    // Lesson routes - Stage 3
    GoRoute(
      path: '/lesson/s3_0_1',
      builder: (context, state) => const AuthGuard(child: LessonS301Screen()),
    ),
    GoRoute(
      path: '/lesson/s3_0_2',
      builder: (context, state) => const AuthGuard(child: LessonS302Screen()),
    ),
    GoRoute(
      path: '/lesson/s3_0_2_1',
      builder: (context, state) => const AuthGuard(child: LessonS3021Screen()),
    ),
  ],
);

// Authentication guard widget
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final UserRole? requiredRole;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiredRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user has completed or partially completed onboarding
        if (!user.onboardingCompleted && !user.onboardingPartiallyCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/onboarding');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check role requirement if specified
        if (requiredRole != null && user.role != requiredRole) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied. Insufficient permissions.'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Initialize auto todos for authenticated user
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            ref.read(autoTodoInitializationProvider(user.id).notifier).initializeTodos();
          } catch (e) {
            print('Error initializing auto todos: $e');
            // Don't disrupt user experience if auto todos fail
          }
        });

        return child;
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        print('❌ Main App Error: $error');
        // On error, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
