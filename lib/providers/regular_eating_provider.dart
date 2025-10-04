import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/regular_eating.dart';
import '../core/services/regular_eating_service.dart';

// Regular eating service provider
final regularEatingServiceProvider = Provider<RegularEatingService>((ref) => RegularEatingService());

// User regular eating settings provider
final userRegularEatingProvider = StateNotifierProvider.family<RegularEatingNotifier, AsyncValue<RegularEating?>, String>((ref, userId) {
  return RegularEatingNotifier(ref.read(regularEatingServiceProvider), userId);
});

// Individual regular eating settings provider (for real-time access)
final regularEatingSettingsProvider = FutureProvider.family<RegularEating?, String>((ref, userId) async {
  final service = ref.read(regularEatingServiceProvider);
  return await service.getUserRegularEatingSettings(userId);
});

// Regular eating history provider
final regularEatingHistoryProvider = FutureProvider.family<List<RegularEating>, String>((ref, userId) async {
  final service = ref.read(regularEatingServiceProvider);
  return await service.getRegularEatingHistory(userId);
});

class RegularEatingNotifier extends StateNotifier<AsyncValue<RegularEating?>> {
  final RegularEatingService _regularEatingService;
  final String _userId;

  RegularEatingNotifier(this._regularEatingService, this._userId) : super(const AsyncValue.loading()) {
    loadRegularEatingSettings();
  }

  Future<void> loadRegularEatingSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _regularEatingService.getUserRegularEatingSettings(_userId);
      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<RegularEating?> saveSettings({
    required double mealIntervalHours,
    required int firstMealHour,
    required int firstMealMinute,
  }) async {
    try {
      // Validate input
      if (mealIntervalHours < RegularEating.minMealIntervalHours || 
          mealIntervalHours > RegularEating.maxMealIntervalHours) {
        throw 'Meal interval must be between ${RegularEating.minMealIntervalHours} and ${RegularEating.maxMealIntervalHours} hours';
      }

      if (firstMealHour < 0 || firstMealHour > 23) {
        throw 'First meal hour must be between 0 and 23';
      }

      if (firstMealMinute < 0 || firstMealMinute > 59) {
        throw 'First meal minute must be between 0 and 59';
      }

      // Get existing ID if available
      final currentSettings = state.value;
      final existingId = currentSettings?.id;

      final savedSettings = await _regularEatingService.saveRegularEatingSettings(
        userId: _userId,
        mealIntervalHours: mealIntervalHours,
        firstMealHour: firstMealHour,
        firstMealMinute: firstMealMinute,
        existingId: existingId,
      );

      // Update state with new settings
      state = AsyncValue.data(savedSettings);
      
      return savedSettings;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> deleteSettings() async {
    try {
      final currentSettings = state.value;
      if (currentSettings != null) {
        await _regularEatingService.deleteRegularEatingSettings(_userId, currentSettings.id);
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshSettings() async {
    await loadRegularEatingSettings();
  }


  // Helper method to get default settings
  RegularEating getDefaultSettings() {
    final now = DateTime.now();
    return RegularEating(
      id: '',
      userId: _userId,
      mealIntervalHours: RegularEating.defaultMealIntervalHours,
      firstMealHour: RegularEating.defaultFirstMealHour,
      firstMealMinute: RegularEating.defaultFirstMealMinute,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper method to get current settings or default
  RegularEating getCurrentOrDefaultSettings() {
    return state.value ?? getDefaultSettings();
  }
}

// Provider for checking if user has regular eating settings
final hasRegularEatingSettingsProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(regularEatingServiceProvider);
  final settings = await service.getUserRegularEatingSettings(userId);
  return settings != null;
});
