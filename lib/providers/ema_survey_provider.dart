import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ema_survey_service.dart';
import '../models/ema_survey.dart';

// EMA Survey service provider
final emaSurveyServiceProvider = Provider<EMASurveyService>((ref) => EMASurveyService());

// Current user's surveys provider
final userSurveysProvider = StreamProvider.family<List<EMASurvey>, String>((ref, userId) {
  if (userId.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(emaSurveyServiceProvider).getUserSurveysStream(userId);
});

// Today's survey provider
final todaySurveyProvider = StreamProvider.family<EMASurvey?, String>((ref, userId) {
  if (userId.isEmpty) {
    return Stream.value(null);
  }
  return ref.watch(emaSurveyServiceProvider).getTodaySurveyStream(userId);
});

// EMA Survey state notifier
class EMASurveyNotifier extends StateNotifier<AsyncValue<EMASurvey?>> {
  EMASurveyNotifier(this._service) : super(const AsyncValue.data(null));

  final EMASurveyService _service;

  // Create or get today's survey
  Future<void> createOrGetTodaySurvey(String userId) async {
    state = const AsyncValue.loading();
    try {
      // First try to get existing survey
      final existingSurvey = await _service.getTodaySurvey(userId);
      if (existingSurvey != null) {
        state = AsyncValue.data(existingSurvey);
        return;
      }

      // Create new survey if none exists
      final newSurvey = await _service.createTodaySurvey(userId);
      state = AsyncValue.data(newSurvey);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Save an answer
  Future<void> saveAnswer(String surveyId, EMASurveyAnswer answer) async {
    try {
      await _service.saveAnswer(surveyId, answer);
      
      // Refresh current survey
      final survey = await _service.getSurveyById(surveyId);
      if (survey != null) {
        state = AsyncValue.data(survey);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Complete survey
  Future<void> completeSurvey(String surveyId) async {
    try {
      await _service.completeSurvey(surveyId);
      
      // Refresh current survey
      final survey = await _service.getSurveyById(surveyId);
      if (survey != null) {
        state = AsyncValue.data(survey);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Delete survey
  Future<void> deleteSurvey(String surveyId) async {
    try {
      await _service.deleteSurvey(surveyId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Load survey by ID
  Future<void> loadSurvey(String surveyId) async {
    state = const AsyncValue.loading();
    try {
      final survey = await _service.getSurveyById(surveyId);
      state = AsyncValue.data(survey);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Clear state
  void clearState() {
    state = const AsyncValue.data(null);
  }
}

// EMA Survey notifier provider
final emaSurveyNotifierProvider = StateNotifierProvider<EMASurveyNotifier, AsyncValue<EMASurvey?>>((ref) {
  return EMASurveyNotifier(ref.watch(emaSurveyServiceProvider));
});

// Convenience providers
final currentSurveyProvider = Provider<EMASurvey?>((ref) {
  final surveyState = ref.watch(emaSurveyNotifierProvider);
  return surveyState.when(
    data: (survey) => survey,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isSurveyLoadingProvider = Provider<bool>((ref) {
  final surveyState = ref.watch(emaSurveyNotifierProvider);
  return surveyState.isLoading;
});

final surveyErrorProvider = Provider<String?>((ref) {
  final surveyState = ref.watch(emaSurveyNotifierProvider);
  return surveyState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});
