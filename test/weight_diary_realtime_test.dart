import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bed_app_1/providers/weight_diary_provider.dart';
import 'package:bed_app_1/models/weight_diary.dart';

void main() {
  group('Weight Diary Real-time Provider Tests', () {
    late ProviderContainer container;
    late FirebaseFirestore mockFirestore;
    late CollectionReference mockCollection;
    late Query mockQuery;
    late QuerySnapshot mockQuerySnapshot;

  

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
      final mockDoc = DocumentSnapshot();
      mockDoc.id = 'test-id';
      mockDoc.data = () => testWeightDiary.toFirestore();
      mockQuerySnapshot.docs = [mockDoc];

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

