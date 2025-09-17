import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../core/services/journal_service.dart';

// Journal service provider
final journalServiceProvider = Provider<JournalService>((ref) => JournalService());

// Journal entries provider
final journalEntriesProvider = StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>((ref) {
  return JournalNotifier(ref.read(journalServiceProvider));
});

// Current user's journal entries
final userJournalEntriesProvider = Provider<AsyncValue<List<JournalEntry>>>((ref) {
  final entries = ref.watch(journalEntriesProvider);
  return entries;
});

// Individual journal entry provider
final journalEntryProvider = StateNotifierProvider.family<JournalEntryNotifier, AsyncValue<JournalEntry?>, String>((ref, entryId) {
  return JournalEntryNotifier(ref.read(journalServiceProvider), entryId);
});

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalService _journalService;

  JournalNotifier(this._journalService) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      state = const AsyncValue.loading();
      // Note: We need userId here, but we'll handle this in the UI
      // For now, return empty list
      state = const AsyncValue.data([]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadUserEntries(String userId) async {
    try {
      state = const AsyncValue.loading();
      final entries = await _journalService.getUserEntries(userId);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createEntry(String userId, String content, {String? mood, List<String>? tags}) async {
    try {
      final entry = await _journalService.createEntry(userId, content, mood: mood, tags: tags);
      
      // Add to current state
      state.whenData((entries) {
        state = AsyncValue.data([entry, ...entries]);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateEntry(String entryId, String content, {String? mood, List<String>? tags}) async {
    try {
      await _journalService.updateEntry(entryId, content, mood: mood, tags: tags);
      
      // Update in current state
      state.whenData((entries) {
        final updatedEntries = entries.map((entry) {
          if (entry.id == entryId) {
            return entry.copyWith(
              content: content,
              mood: mood,
              tags: tags,
              updatedAt: DateTime.now(),
            );
          }
          return entry;
        }).toList();
        state = AsyncValue.data(updatedEntries);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _journalService.deleteEntry(entryId);
      
      // Remove from current state
      state.whenData((entries) {
        final updatedEntries = entries.where((entry) => entry.id != entryId).toList();
        state = AsyncValue.data(updatedEntries);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshEntries(String userId) async {
    await loadUserEntries(userId);
  }
}

class JournalEntryNotifier extends StateNotifier<AsyncValue<JournalEntry?>> {
  final JournalService _journalService;
  final String _entryId;

  JournalEntryNotifier(this._journalService, this._entryId) : super(const AsyncValue.loading()) {
    loadEntry();
  }

  Future<void> loadEntry() async {
    try {
      state = const AsyncValue.loading();
      final entry = await _journalService.getEntry(_entryId);
      state = AsyncValue.data(entry);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateEntry(String content, {String? mood, List<String>? tags}) async {
    try {
      await _journalService.updateEntry(_entryId, content, mood: mood, tags: tags);
      
      // Update current state
      state.whenData((entry) {
        if (entry != null) {
          state = AsyncValue.data(entry.copyWith(
            content: content,
            mood: mood,
            tags: tags,
            updatedAt: DateTime.now(),
          ));
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry() async {
    try {
      await _journalService.deleteEntry(_entryId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
