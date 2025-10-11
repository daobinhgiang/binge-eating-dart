import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bed_app_1/providers/weight_diary_provider.dart';
import 'package:bed_app_1/models/weight_diary.dart';

void main() {
  group('Weight Diary Real-time Provider Tests', () {
    late ProviderContainer container;
    late FakeFirebaseFirestore fakeFirestore;

  

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

      fakeFirestore = FakeFirebaseFirestore();

      // Seed fake Firestore with current week data
      await fakeFirestore
          .collection('users')
          .doc('test-user-id')
          .collection('weeks')
          .doc('week_1')
          .collection('weightDiaries')
          .add(testWeightDiary.toFirestore());

      container = ProviderContainer(
        overrides: [
          // Use fake Firestore for the stream provider
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          // Force current week to 1 so historical fetch is skipped
          currentWeekNumberProvider('test-user-id').overrideWith((ref) async => 1),
        ],
      );

      final stream = container
          .read(allWeightEntriesStreamProvider('test-user-id').stream);

      // Take first emission
      final emitted = await stream.first;

      expect(emitted.isNotEmpty, true);
      expect(emitted.length, 1);
      expect(emitted.first.id, isNotEmpty);
      expect(emitted.first.weight, 70.0);
    });

    tearDown(() {
      container.dispose();
    });
  });
}

