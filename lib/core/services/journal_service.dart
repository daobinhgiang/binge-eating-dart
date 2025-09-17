import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/journal_entry.dart';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;
  JournalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new journal entry
  Future<JournalEntry> createEntry(String userId, String content, {String? mood, List<String>? tags}) async {
    try {
      final now = DateTime.now();
      final entry = JournalEntry(
        id: '', // Will be set by Firestore
        userId: userId,
        content: content,
        createdAt: now,
        updatedAt: now,
        mood: mood,
        tags: tags ?? [],
      );

      final docRef = await _firestore
          .collection('journal_entries')
          .add(entry.toFirestore());
      
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create journal entry: $e';
    }
  }

  // Get all journal entries for a user
  Future<List<JournalEntry>> getUserEntries(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get journal entries: $e';
    }
  }

  // Get a specific journal entry by ID
  Future<JournalEntry?> getEntry(String entryId) async {
    try {
      final doc = await _firestore
          .collection('journal_entries')
          .doc(entryId)
          .get();

      if (doc.exists) {
        return JournalEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get journal entry: $e';
    }
  }

  // Update a journal entry
  Future<void> updateEntry(String entryId, String content, {String? mood, List<String>? tags}) async {
    try {
      await _firestore
          .collection('journal_entries')
          .doc(entryId)
          .update({
        'content': content,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'mood': mood,
        'tags': tags ?? [],
      });
    } catch (e) {
      throw 'Failed to update journal entry: $e';
    }
  }

  // Delete a journal entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore
          .collection('journal_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete journal entry: $e';
    }
  }

  // Get entries for a specific date range
  Future<List<JournalEntry>> getEntriesByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('createdAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get journal entries by date range: $e';
    }
  }

  // Search entries by content
  Future<List<JournalEntry>> searchEntries(String userId, String query) async {
    try {
      // Note: This is a simple implementation. For better search, consider using Algolia or similar
      final allEntries = await getUserEntries(userId);
      return allEntries
          .where((entry) => 
              entry.content.toLowerCase().contains(query.toLowerCase()) ||
              (entry.mood?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              entry.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          )
          .toList();
    } catch (e) {
      throw 'Failed to search journal entries: $e';
    }
  }
}
