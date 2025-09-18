import 'package:flutter/material.dart';

/// Custom page transition utilities for smooth, beautiful animations
class PageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// Slide transition from right (iOS-style)
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Slide transition from left (back navigation)
  static Widget slideFromLeft(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Fade transition with scale
  static Widget fadeScale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }

  /// Slide up transition (modal-style)
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Slide down transition (dismiss modal)
  static Widget slideDown(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, -1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Hero-style transition with shared elements
  static Widget heroTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        )),
        child: child,
      ),
    );
  }

  /// Platform-adaptive transition
  static Widget platformAdaptive(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use Theme.of(context).platform for cross-platform compatibility
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return slideFromRight(context, animation, secondaryAnimation, child);
    } else {
      return fadeScale(context, animation, secondaryAnimation, child);
    }
  }

  /// Bottom navigation transition (smooth tab switching)
  static Widget bottomNavTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }

  /// Lesson navigation transition (educational content)
  static Widget lessonTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        )),
        child: child,
      ),
    );
  }

  /// Auth screen transition (login/register)
  static Widget authTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

/// Custom page class for GoRouter with transitions
class CustomPage<T> extends Page<T> {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;

  const CustomPage({
    required this.child,
    this.transitionType = TransitionType.platformAdaptive,
    this.duration = PageTransitions.defaultDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return CustomMaterialPageRoute<T>(
      builder: (context) => child,
      transitionType: transitionType,
      duration: duration,
      settings: this,
    );
  }
}

/// Custom page route builders
class CustomPageRouteBuilder {
  /// Slide from right route
  static PageRouteBuilder slideFromRight({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.slideFromRight,
    );
  }

  /// Fade with scale route
  static PageRouteBuilder fadeScale({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.fadeScale,
    );
  }

  /// Slide up route (modal)
  static PageRouteBuilder slideUp({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.slideUp,
    );
  }

  /// Platform adaptive route
  static PageRouteBuilder platformAdaptive({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.platformAdaptive,
    );
  }

  /// Lesson navigation route
  static PageRouteBuilder lessonRoute({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.lessonTransition,
    );
  }

  /// Auth screen route
  static PageRouteBuilder authRoute({
    required Widget child,
    Duration duration = PageTransitions.defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: PageTransitions.authTransition,
    );
  }
}

/// Enhanced MaterialPageRoute with custom transitions
class CustomMaterialPageRoute<T> extends MaterialPageRoute<T> {
  CustomMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.transitionType = TransitionType.slideFromRight,
    this.duration = PageTransitions.defaultDuration,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  final TransitionType transitionType;
  final Duration duration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case TransitionType.slideFromRight:
        return PageTransitions.slideFromRight(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.slideFromLeft:
        return PageTransitions.slideFromLeft(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.fadeScale:
        return PageTransitions.fadeScale(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.slideUp:
        return PageTransitions.slideUp(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.slideDown:
        return PageTransitions.slideDown(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.hero:
        return PageTransitions.heroTransition(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.platformAdaptive:
        return PageTransitions.platformAdaptive(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.lesson:
        return PageTransitions.lessonTransition(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.auth:
        return PageTransitions.authTransition(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case TransitionType.bottomNav:
        return PageTransitions.bottomNavTransition(
          context,
          animation,
          secondaryAnimation,
          child,
        );
    }
  }

  @override
  Duration get transitionDuration => duration;
}

/// Transition types enum
enum TransitionType {
  slideFromRight,
  slideFromLeft,
  fadeScale,
  slideUp,
  slideDown,
  hero,
  platformAdaptive,
  lesson,
  auth,
  bottomNav,
}

/// Navigation helper with enhanced transitions
class NavigationHelper {
  /// Navigate to a lesson with custom transition
  static Future<T?> navigateToLesson<T extends Object?>(
    BuildContext context,
    Widget lessonScreen, {
    TransitionType transitionType = TransitionType.lesson,
    Duration duration = PageTransitions.defaultDuration,
  }) {
    return Navigator.push<T>(
      context,
      CustomMaterialPageRoute<T>(
        builder: (context) => lessonScreen,
        transitionType: transitionType,
        duration: duration,
      ),
    );
  }

  /// Navigate to auth screen with custom transition
  static Future<T?> navigateToAuth<T extends Object?>(
    BuildContext context,
    Widget authScreen, {
    TransitionType transitionType = TransitionType.auth,
    Duration duration = PageTransitions.defaultDuration,
  }) {
    return Navigator.push<T>(
      context,
      CustomMaterialPageRoute<T>(
        builder: (context) => authScreen,
        transitionType: transitionType,
        duration: duration,
      ),
    );
  }

  /// Navigate with platform-adaptive transition
  static Future<T?> navigateAdaptive<T extends Object?>(
    BuildContext context,
    Widget screen, {
    Duration duration = PageTransitions.defaultDuration,
  }) {
    return Navigator.push<T>(
      context,
      CustomMaterialPageRoute<T>(
        builder: (context) => screen,
        transitionType: TransitionType.platformAdaptive,
        duration: duration,
      ),
    );
  }

  /// Present modal with slide up transition
  static Future<T?> presentModal<T extends Object?>(
    BuildContext context,
    Widget modalScreen, {
    Duration duration = PageTransitions.defaultDuration,
  }) {
    return Navigator.push<T>(
      context,
      CustomMaterialPageRoute<T>(
        builder: (context) => modalScreen,
        transitionType: TransitionType.slideUp,
        duration: duration,
        fullscreenDialog: true,
      ),
    );
  }
}
