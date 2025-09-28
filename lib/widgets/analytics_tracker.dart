import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_analytics_provider.dart';

/// Widget that tracks app lifecycle events for analytics
class AnalyticsTracker extends ConsumerStatefulWidget {
  final Widget child;

  const AnalyticsTracker({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AnalyticsTracker> createState() => _AnalyticsTrackerState();
}

class _AnalyticsTrackerState extends ConsumerState<AnalyticsTracker>
    with WidgetsBindingObserver {
  DateTime? _appStartTime;
  DateTime? _lastResumeTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appStartTime = DateTime.now();
    
    // Initialize analytics and track app open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackAppOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackSessionDuration();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _lastResumeTime = DateTime.now();
        _trackAppResume();
        break;
      case AppLifecycleState.paused:
        _trackAppPause();
        break;
      case AppLifecycleState.detached:
        _trackSessionDuration();
        break;
      case AppLifecycleState.inactive:
        // App is transitioning between states
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        break;
    }
  }

  void _trackAppOpen() {
    try {
      final trackAppOpen = ref.read(appOpenTrackingProvider);
      trackAppOpen();
    } catch (e) {
      print('Error tracking app open: $e');
    }
  }

  void _trackAppResume() {
    try {
      final trackAppOpen = ref.read(appOpenTrackingProvider);
      trackAppOpen();
    } catch (e) {
      print('Error tracking app resume: $e');
    }
  }

  void _trackAppPause() {
    try {
      final trackSession = ref.read(sessionTrackingProvider);
      if (_lastResumeTime != null) {
        final sessionDuration = DateTime.now().difference(_lastResumeTime!).inSeconds;
        trackSession(sessionDuration);
      }
    } catch (e) {
      print('Error tracking app pause: $e');
    }
  }

  void _trackSessionDuration() {
    try {
      final trackSession = ref.read(sessionTrackingProvider);
      if (_appStartTime != null) {
        final totalSessionDuration = DateTime.now().difference(_appStartTime!).inSeconds;
        trackSession(totalSessionDuration);
      }
    } catch (e) {
      print('Error tracking session duration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
