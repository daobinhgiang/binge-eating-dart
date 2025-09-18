import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'screens/main_navigation.dart';
import 'screens/education/article_detail_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/onboarding_review_screen.dart';
import 'screens/ema_survey/ema_survey_screen.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';
import 'core/utils/page_transitions.dart';
import 'screens/lessons/lesson_1_1.dart';
import 'screens/lessons/lesson_1_2.dart';
import 'screens/lessons/lesson_1_3.dart';
import 'screens/lessons/lesson_2_1.dart';
import 'screens/lessons/lesson_2_2.dart';
import 'screens/lessons/lesson_2_3.dart';
import 'screens/lessons/lesson_2_4.dart';
import 'screens/lessons/lesson_2_5.dart';
import 'screens/lessons/lesson_2_6.dart';
import 'screens/lessons/lesson_3_1.dart';
import 'screens/lessons/lesson_3_2.dart';
import 'screens/lessons/lesson_3_3.dart';
import 'screens/lessons/lesson_3_4.dart';
import 'screens/lessons/lesson_4_1.dart';
import 'screens/lessons/lesson_4_2.dart';
import 'screens/lessons/lesson_4_3.dart';
import 'screens/lessons/lesson_4_4.dart';
import 'screens/lessons/lesson_4_5.dart';
import 'screens/lessons/lesson_5_1.dart';
import 'screens/lessons/lesson_5_2.dart';
import 'screens/lessons/lesson_5_3.dart';
import 'screens/lessons/lesson_5_4.dart';
import 'screens/lessons/lesson_5_5.dart';
import 'screens/lessons/lesson_5_6.dart';
import 'screens/lessons/lesson_6_1.dart';
import 'screens/lessons/lesson_6_2.dart';
import 'screens/lessons/lesson_6_3.dart';
import 'screens/lessons/lesson_6_4.dart';
import 'screens/lessons/lesson_6_5.dart';
import 'screens/lessons/lesson_6_6.dart';
import 'screens/lessons/lesson_7_1.dart';
import 'screens/lessons/lesson_7_2.dart';
import 'screens/lessons/lesson_7_3.dart';
import 'screens/lessons/lesson_7_4.dart';
import 'screens/lessons/lesson_8_1.dart';
import 'screens/lessons/lesson_8_2.dart';
import 'screens/lessons/lesson_8_3.dart';
import 'screens/lessons/lesson_8_4.dart';
import 'screens/lessons/lesson_9_1.dart';
import 'screens/lessons/lesson_9_2.dart';
import 'screens/lessons/lesson_9_3.dart';
import 'screens/lessons/lesson_9_4.dart';
import 'screens/lessons/lesson_9_5.dart';
import 'screens/lessons/lesson_9_6.dart';
import 'screens/lessons/lesson_10_1.dart';
import 'screens/lessons/lesson_10_2.dart';
import 'screens/lessons/lesson_10_3.dart';
import 'screens/lessons/lesson_10_4.dart';
import 'screens/lessons/lesson_10_5.dart';
import 'screens/lessons/lesson_11_1.dart';
import 'screens/lessons/lesson_11_2.dart';
import 'screens/lessons/lesson_11_3.dart';
import 'screens/lessons/lesson_12_1.dart';
import 'screens/lessons/lesson_12_2.dart';
import 'screens/lessons/lesson_12_3.dart';
import 'screens/lessons/lesson_12_4.dart';
import 'screens/lessons/lesson_13_1.dart';
import 'screens/lessons/lesson_13_2.dart';
import 'screens/lessons/lesson_13_3.dart';
import 'screens/lessons/lesson_13_4.dart';
import 'screens/lessons/lesson_14_1.dart';
import 'screens/lessons/lesson_14_2.dart';
import 'screens/lessons/lesson_14_3.dart';
import 'screens/lessons/lesson_14_4.dart';
import 'screens/lessons/lesson_15_1.dart';
import 'screens/lessons/lesson_15_2.dart';
import 'screens/lessons/lesson_16_1.dart';
import 'screens/lessons/lesson_16_2.dart';
import 'screens/lessons/lesson_16_3.dart';
import 'screens/lessons/lesson_17_1.dart';
import 'screens/lessons/lesson_17_2.dart';
import 'screens/lessons/lesson_17_3.dart';
import 'screens/lessons/lesson_17_4.dart';
import 'screens/lessons/lesson_18_1.dart';
import 'screens/lessons/lesson_18_2.dart';
import 'screens/lessons/lesson_18_3.dart';
import 'screens/lessons/lesson_18_4.dart';
import 'screens/lessons/appendix_1_1.dart';
import 'screens/lessons/appendix_1_2.dart';
import 'screens/lessons/appendix_1_3.dart';
import 'screens/lessons/appendix_2_1.dart';
import 'screens/lessons/appendix_2_2.dart';
import 'screens/lessons/appendix_2_3.dart';
import 'screens/lessons/appendix_2_4.dart';
import 'screens/lessons/appendix_3_1.dart';
import 'screens/lessons/appendix_3_2.dart';
import 'screens/lessons/appendix_4_1.dart';
import 'screens/lessons/appendix_4_2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use path-based routing instead of hash-based routing
  usePathUrlStrategy();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: BEDApp()));
}

/// Helper function to get lesson screen widget based on chapter and lesson number
Widget? _getLessonScreen(int chapterNumber, int lessonNumber) {
  // Handle appendices (101-104)
  if (chapterNumber >= 101 && chapterNumber <= 104) {
    final appendixNumber = chapterNumber - 100;
    switch (appendixNumber) {
      case 1:
        switch (lessonNumber) {
          case 1: return const Appendix11Screen();
          case 2: return const Appendix12Screen();
          case 3: return const Appendix13Screen();
        }
        break;
      case 2:
        switch (lessonNumber) {
          case 1: return const Appendix21Screen();
          case 2: return const Appendix22Screen();
          case 3: return const Appendix23Screen();
          case 4: return const Appendix24Screen();
        }
        break;
      case 3:
        switch (lessonNumber) {
          case 1: return const Appendix31Screen();
          case 2: return const Appendix32Screen();
        }
        break;
      case 4:
        switch (lessonNumber) {
          case 1: return const Appendix41Screen();
          case 2: return const Appendix42Screen();
        }
        break;
    }
    return null;
  }
  
  // Handle regular chapters (1-18)
  switch (chapterNumber) {
    case 1:
      switch (lessonNumber) {
        case 1: return const Lesson11Screen();
        case 2: return const Lesson12Screen();
        case 3: return const Lesson13Screen();
      }
      break;
    case 2:
      switch (lessonNumber) {
        case 1: return const Lesson21Screen();
        case 2: return const Lesson22Screen();
        case 3: return const Lesson23Screen();
        case 4: return const Lesson24Screen();
        case 5: return const Lesson25Screen();
        case 6: return const Lesson26Screen();
      }
      break;
    case 3:
      switch (lessonNumber) {
        case 1: return const Lesson31Screen();
        case 2: return const Lesson32Screen();
        case 3: return const Lesson33Screen();
        case 4: return const Lesson34Screen();
      }
      break;
    case 4:
      switch (lessonNumber) {
        case 1: return const Lesson41Screen();
        case 2: return const Lesson42Screen();
        case 3: return const Lesson43Screen();
        case 4: return const Lesson44Screen();
        case 5: return const Lesson45Screen();
      }
      break;
    case 5:
      switch (lessonNumber) {
        case 1: return const Lesson51Screen();
        case 2: return const Lesson52Screen();
        case 3: return const Lesson53Screen();
        case 4: return const Lesson54Screen();
        case 5: return const Lesson55Screen();
        case 6: return const Lesson56Screen();
      }
      break;
    case 6:
      switch (lessonNumber) {
        case 1: return const Lesson61Screen();
        case 2: return const Lesson62Screen();
        case 3: return const Lesson63Screen();
        case 4: return const Lesson64Screen();
        case 5: return const Lesson65Screen();
        case 6: return const Lesson66Screen();
      }
      break;
    case 7:
      switch (lessonNumber) {
        case 1: return const Lesson71Screen();
        case 2: return const Lesson72Screen();
        case 3: return const Lesson73Screen();
        case 4: return const Lesson74Screen();
      }
      break;
    case 8:
      switch (lessonNumber) {
        case 1: return const Lesson81Screen();
        case 2: return const Lesson82Screen();
        case 3: return const Lesson83Screen();
        case 4: return const Lesson84Screen();
      }
      break;
    case 9:
      switch (lessonNumber) {
        case 1: return const Lesson91Screen();
        case 2: return const Lesson92Screen();
        case 3: return const Lesson93Screen();
        case 4: return const Lesson94Screen();
        case 5: return const Lesson95Screen();
        case 6: return const Lesson96Screen();
      }
      break;
    case 10:
      switch (lessonNumber) {
        case 1: return const Lesson101Screen();
        case 2: return const Lesson102Screen();
        case 3: return const Lesson103Screen();
        case 4: return const Lesson104Screen();
        case 5: return const Lesson105Screen();
      }
      break;
    case 11:
      switch (lessonNumber) {
        case 1: return const Lesson111Screen();
        case 2: return const Lesson112Screen();
        case 3: return const Lesson113Screen();
      }
      break;
    case 12:
      switch (lessonNumber) {
        case 1: return const Lesson121Screen();
        case 2: return const Lesson122Screen();
        case 3: return const Lesson123Screen();
        case 4: return const Lesson124Screen();
      }
      break;
    case 13:
      switch (lessonNumber) {
        case 1: return const Lesson131Screen();
        case 2: return const Lesson132Screen();
        case 3: return const Lesson133Screen();
        case 4: return const Lesson134Screen();
      }
      break;
    case 14:
      switch (lessonNumber) {
        case 1: return const Lesson141Screen();
        case 2: return const Lesson142Screen();
        case 3: return const Lesson143Screen();
        case 4: return const Lesson144Screen();
      }
      break;
    case 15:
      switch (lessonNumber) {
        case 1: return const Lesson151Screen();
        case 2: return const Lesson152Screen();
      }
      break;
    case 16:
      switch (lessonNumber) {
        case 1: return const Lesson161Screen();
        case 2: return const Lesson162Screen();
        case 3: return const Lesson163Screen();
      }
      break;
    case 17:
      switch (lessonNumber) {
        case 1: return const Lesson171Screen();
        case 2: return const Lesson172Screen();
        case 3: return const Lesson173Screen();
        case 4: return const Lesson174Screen();
      }
      break;
    case 18:
      switch (lessonNumber) {
        case 1: return const Lesson181Screen();
        case 2: return const Lesson182Screen();
        case 3: return const Lesson183Screen();
        case 4: return const Lesson184Screen();
      }
      break;
  }
  return null;
}

class BEDApp extends ConsumerWidget {
  const BEDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BED Support App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1), // Purple theme for calm, supportive feel
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
              color: const Color(0xFF6B46C1),
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
            backgroundColor: const Color(0xFF6B46C1),
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
      pageBuilder: (context, state) => CustomPage(
        child: const AuthGuard(child: MainNavigation()),
        transitionType: TransitionType.platformAdaptive,
        name: state.uri.path,
      ),
      routes: [
        GoRoute(
          path: 'home',
          pageBuilder: (context, state) => CustomPage(
            child: const AuthGuard(child: MainNavigation()),
            transitionType: TransitionType.platformAdaptive,
            name: state.uri.path,
          ),
        ),
        GoRoute(
          path: 'education',
          pageBuilder: (context, state) => CustomPage(
            child: const AuthGuard(child: MainNavigation()),
            transitionType: TransitionType.platformAdaptive,
            name: state.uri.path,
          ),
        ),
        GoRoute(
          path: 'journal',
          pageBuilder: (context, state) => CustomPage(
            child: const AuthGuard(child: MainNavigation()),
            transitionType: TransitionType.platformAdaptive,
            name: state.uri.path,
          ),
        ),
        GoRoute(
          path: 'profile',
          pageBuilder: (context, state) => CustomPage(
            child: const AuthGuard(child: MainNavigation()),
            transitionType: TransitionType.platformAdaptive,
            name: state.uri.path,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomPage(
        child: const LoginScreen(),
        transitionType: TransitionType.fadeScale,
        name: state.uri.path,
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => CustomPage(
        child: const RegisterScreen(),
        transitionType: TransitionType.fadeScale,
        name: state.uri.path,
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomPage(
        child: const OnboardingScreen(),
        transitionType: TransitionType.slideUp,
        name: state.uri.path,
      ),
    ),
    GoRoute(
      path: '/onboarding/review',
      pageBuilder: (context, state) => CustomPage(
        child: const AuthGuard(child: OnboardingReviewScreen()),
        transitionType: TransitionType.slideUp,
        name: state.uri.path,
      ),
    ),
    GoRoute(
      path: '/education/article/:id',
      pageBuilder: (context, state) {
        final articleId = state.pathParameters['id']!;
        return CustomPage(
          child: AuthGuard(child: ArticleDetailScreen(articleId: articleId)),
          transitionType: TransitionType.platformAdaptive,
          name: state.uri.path,
        );
      },
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => CustomPage(
        child: const AuthGuard(
          requiredRole: UserRole.clinician,
          child: AdminScreen(),
        ),
        transitionType: TransitionType.platformAdaptive,
        name: state.uri.path,
      ),
    ),
    GoRoute(
      path: '/ema-survey',
      pageBuilder: (context, state) {
        final isResuming = state.uri.queryParameters['resuming'] == 'true';
        return CustomPage(
          child: AuthGuard(
            child: EMASurveyScreen(isResuming: isResuming),
          ),
          transitionType: TransitionType.slideUp,
          name: state.uri.path,
        );
      },
    ),
    GoRoute(
      path: '/ema-survey/resume',
      pageBuilder: (context, state) => CustomPage(
        child: AuthGuard(
          child: EMASurveyScreen(isResuming: true),
        ),
        transitionType: TransitionType.slideUp,
        name: state.uri.path,
      ),
    ),
    // Lesson routes with custom transitions
    GoRoute(
      path: '/lesson/:chapter/:lesson',
      pageBuilder: (context, state) {
        final chapter = int.tryParse(state.pathParameters['chapter'] ?? '');
        final lesson = int.tryParse(state.pathParameters['lesson'] ?? '');
        
        if (chapter == null || lesson == null) {
          return CustomPage(
            child: const Scaffold(
              body: Center(child: Text('Invalid lesson parameters')),
            ),
            transitionType: TransitionType.fadeScale,
            name: state.uri.path,
          );
        }
        
        final lessonScreen = _getLessonScreen(chapter, lesson);
        if (lessonScreen == null) {
          return CustomPage(
            child: const Scaffold(
              body: Center(child: Text('Lesson not found')),
            ),
            transitionType: TransitionType.fadeScale,
            name: state.uri.path,
          );
        }
        
        return CustomPage(
          child: lessonScreen,
          transitionType: TransitionType.lesson,
          name: state.uri.path,
        );
      },
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
