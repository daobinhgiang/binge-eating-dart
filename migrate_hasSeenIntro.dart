import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// One-time migration script to add hasSeenIntro field to existing users
/// Run this with: dart migrate_hasSeenIntro.dart
Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  print('🔄 Starting migration: Adding hasSeenIntro field to existing users...');
  
  try {
    // Get all users
    final usersSnapshot = await firestore.collection('users').get();
    
    print('📊 Found ${usersSnapshot.docs.length} users');
    
    int updated = 0;
    int skipped = 0;
    
    // Update each user
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      
      // Check if hasSeenIntro field already exists
      if (data.containsKey('hasSeenIntro')) {
        print('⏭️  Skipping user ${doc.id} (already has hasSeenIntro field)');
        skipped++;
        continue;
      }
      
      // Add hasSeenIntro = true for existing users
      // (so they don't have to see the intro again)
      await doc.reference.update({
        'hasSeenIntro': true,
      });
      
      print('✅ Updated user ${doc.id}');
      updated++;
    }
    
    print('\n🎉 Migration complete!');
    print('   - Updated: $updated users');
    print('   - Skipped: $skipped users');
    print('   - Total: ${usersSnapshot.docs.length} users');
    
  } catch (e) {
    print('❌ Migration failed: $e');
  }
}

