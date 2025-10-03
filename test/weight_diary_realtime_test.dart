import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/providers/weight_diary_provider.dart';
import '../lib/models/weight_diary.dart';

// Generate mocks for testing
@GenerateMocks([FirebaseFirestore, CollectionReference, Query, QuerySnapshot, DocumentSnapshot])
import 'weight_diary_realtime_test.mocks.dart';

void main() {
  group('Weight Diary Real-time Provider Tests', () {
    late ProviderContainer container;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockQuery mockQuery;
    late MockQuerySnapshot mockQuerySnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      mockQuerySnapshot = MockQuerySnapshot();
      
      // Setup mocks
      when(mockFirestore.collectionGroup('weightDiaries')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: false)).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
    });

    testWidgets('Real-time provider should emit data when Firestore updates', (tester) async {
      // Create test data
      final testWeightDiary = WeightDiary(
        id: 'test-id',
        userId: 'test-user-id',
        week: 1,
        weight: 70.0,
        unit: 'kg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock document snapshot
      final mockDoc = MockDocumentSnapshot();
      when(mockDoc.id).thenReturn('test-id');
      when(mockDoc.data()).thenReturn(testWeightDiary.toFirestore());
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      container = ProviderContainer(
        overrides: [
          // Override FirebaseFirestore.instance with our mock
        ],
      );

      // Test the stream provider
      final streamProvider = allWeightEntriesStreamProvider('test-user-id');
      final stream = container.read(streamProvider.stream);
      
      // Listen to the stream and verify it emits the correct data
      final results = <List<WeightDiary>>[];
      stream.listen((data) {
        results.add(data);
      });

      // Wait for the stream to emit
      await tester.pumpAndSettle();

      // Verify that the stream emitted the correct data
      expect(results.isNotEmpty, true);
      expect(results.first.length, 1);
      expect(results.first.first.id, 'test-id');
      expect(results.first.first.weight, 70.0);
    });

    tearDown(() {
      container.dispose();
    });
  });
}

