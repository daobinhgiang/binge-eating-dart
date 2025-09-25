import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/analytics_service.dart';
import './todo_provider.dart';

// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService());

// Analytics notifier for managing analysis state
final analyticsNotifierProvider = StateNotifierProvider.family<AnalyticsNotifier, AsyncValue<Map<String, dynamic>?>, String>((ref, userId) {
  return AnalyticsNotifier(ref.read(analyticsServiceProvider), userId, ref);
});

// Provider for latest analysis
final latestAnalysisProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final service = ref.read(analyticsServiceProvider);
  return await service.getLatestAnalysis(userId);
});

class AnalyticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AnalyticsService _analyticsService;
  final String _userId;
  final Ref _ref;

  AnalyticsNotifier(this._analyticsService, this._userId, this._ref) : super(const AsyncValue.data(null)) {
    // Load any existing cached analysis on initialization
    loadLatestAnalysis();
  }

  // Load the latest cached analysis
  Future<void> loadLatestAnalysis() async {
    try {
      state = const AsyncValue.loading();
      final analysis = await _analyticsService.getLatestAnalysis(_userId);
      state = AsyncValue.data(analysis);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Generate new analysis
  Future<void> generateAnalysis() async {
    try {
      state = const AsyncValue.loading();
      
      // Generate analysis with AI-recommended todos using OpenAI
      final analysis = await _analyticsService.generateJournalAnalysisWithRecommendations(_userId);
      
      // Store the analysis for caching
      await _analyticsService.storeAnalysis(_userId, analysis);
      
      // Update state with new analysis
      state = AsyncValue.data(analysis);
      
      // If todos were generated, refresh the todo provider to show new items
      if (analysis['todosGenerated'] == true && analysis['recommendedTodos'] != null && analysis['recommendedTodos'] > 0) {
        // Trigger a refresh of the todo provider
        _ref.read(userTodosProvider(_userId).notifier).refreshTodos();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Refresh analysis by generating a new one
  Future<void> refreshAnalysis() async {
    await generateAnalysis();
  }

  // Check if analysis exists and is recent
  bool get hasRecentAnalysis {
    return state.when(
      data: (analysis) {
        if (analysis == null) return false;
        
        final generatedAt = analysis['generatedAt'] as String?;
        if (generatedAt == null) return false;
        
        try {
          final generatedTime = DateTime.parse(generatedAt);
          final now = DateTime.now();
          final difference = now.difference(generatedTime).inHours;
          
          // Consider analysis recent if it's less than 24 hours old
          return difference < 24;
        } catch (e) {
          return false;
        }
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Get analysis summary for display
  String? get analysisSummary {
    return state.when(
      data: (analysis) => analysis?['analysis'] as String?,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Get insights list
  List<String> get insights {
    return state.when(
      data: (analysis) {
        if (analysis == null) return [];
        final insights = analysis['insights'] as List?;
        return insights?.cast<String>() ?? [];
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get patterns list
  List<String> get patterns {
    return state.when(
      data: (analysis) {
        if (analysis == null) return [];
        final patterns = analysis['patterns'] as List?;
        return patterns?.cast<String>() ?? [];
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get recommendations list
  List<String> get recommendations {
    return state.when(
      data: (analysis) {
        if (analysis == null) return [];
        final recommendations = analysis['recommendations'] as List?;
        return recommendations?.cast<String>() ?? [];
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get week number that was analyzed
  int? get analyzedWeekNumber {
    return state.when(
      data: (analysis) => analysis?['weekNumber'] as int?,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Get number of entries analyzed
  int? get entriesAnalyzed {
    return state.when(
      data: (analysis) => analysis?['entriesAnalyzed'] as int?,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Get number of recommended todos
  int get recommendedTodosCount {
    return state.when(
      data: (analysis) => analysis?['recommendedTodos'] as int? ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Check if todos were generated
  bool get todosGenerated {
    return state.when(
      data: (analysis) => analysis?['todosGenerated'] as bool? ?? false,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Clear analysis
  void clearAnalysis() {
    state = const AsyncValue.data(null);
  }
}
