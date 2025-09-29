import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auto_todo_service.dart';

// Auto todo service provider
final autoTodoServiceProvider = Provider<AutoTodoService>((ref) => AutoTodoService());

// Provider to track auto todo initialization state
final autoTodoInitializationProvider = StateNotifierProvider.family<AutoTodoNotifier, AsyncValue<void>, String>((ref, userId) {
  return AutoTodoNotifier(ref.read(autoTodoServiceProvider), userId);
});

class AutoTodoNotifier extends StateNotifier<AsyncValue<void>> {
  final AutoTodoService _autoTodoService;
  final String _userId;

  AutoTodoNotifier(this._autoTodoService, this._userId) : super(const AsyncValue.data(null));

  /// Initialize auto todos for user
  Future<void> initializeTodos() async {
    if (state.isLoading) return; // Prevent multiple simultaneous initializations
    
    state = const AsyncValue.loading();
    try {
      await _autoTodoService.initializeUserTodos(_userId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Don't rethrow - this should be a background operation
    }
  }

  /// Refresh todos manually
  Future<void> refreshTodos() async {
    state = const AsyncValue.loading();
    try {
      await _autoTodoService.refreshUserTodos(_userId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Mark lesson as completed and update todos
  Future<void> markLessonCompleted(String lessonId) async {
    try {
      await _autoTodoService.markLessonCompleted(_userId, lessonId);
      // Don't update state here as it will be updated by todo refresh
    } catch (e) {
      print('Error marking lesson completed: $e');
      // Don't update state with error as this is a background operation
    }
  }

  /// Get current initialization state
  bool get isInitialized => state.hasValue && !state.isLoading;
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
}
