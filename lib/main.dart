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
import 'screens/ema_survey/ema_survey_screen.dart';
import 'screens/tools/problem_solving_main_screen.dart';
import 'screens/tools/meal_planning_screen.dart';
import 'screens/tools/urge_surfing_screen.dart';
import 'screens/tools/purge_control_screen.dart';
import 'screens/tools/addressing_overconcern_screen.dart';
import 'screens/tools/shape_checking_screen.dart';
import 'screens/tools/addressing_comparisons_screen.dart';
import 'screens/tools/addressing_feeling_fat_screen.dart';
import 'screens/tools/addressing_setbacks_screen.dart';
import 'screens/todos/todos_screen.dart';
import 'screens/todos/add_todo_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/profile/regular_eating_screen.dart';
import 'screens/profile/notification_settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
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
      path: '/ema-survey',
      builder: (context, state) {
        final isResuming = state.uri.queryParameters['resuming'] == 'true';
        return AuthGuard(
          child: EMASurveyScreen(isResuming: isResuming),
        );
      },
    ),
    GoRoute(
      path: '/ema-survey/resume',
      builder: (context, state) {
        return AuthGuard(
          child: EMASurveyScreen(isResuming: true),
        );
      },
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
      path: '/tools/purge-control',
      builder: (context, state) => const AuthGuard(child: PurgeControlScreen()),
    ),
    GoRoute(
      path: '/tools/addressing-overconcern',
      builder: (context, state) => const AuthGuard(child: AddressingOverconcernScreen()),
    ),
    GoRoute(
      path: '/tools/shape-checking',
      builder: (context, state) => const AuthGuard(child: ShapeCheckingScreen()),
    ),
    GoRoute(
      path: '/tools/addressing-comparisons',
      builder: (context, state) => const AuthGuard(child: AddressingComparisonsScreen()),
    ),
    GoRoute(
      path: '/tools/addressing-feeling-fat',
      builder: (context, state) => const AuthGuard(child: AddressingFeelingFatScreen()),
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
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const AuthGuard(child: ChatbotScreen()),
    ),
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
