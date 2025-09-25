import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'sample_data.dart';

Future<void> populateDatabase() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final sampleArticles = SampleData.getSampleArticles();

  print('Starting to populate database with ${sampleArticles.length} articles...');

  try {
    // Add each article to Firestore
    for (final article in sampleArticles) {
      await firestore.collection('articles').doc(article.id).set(article.toMap());
      print('Added article: ${article.title}');
    }

    print('Database populated successfully!');
  } catch (e) {
    print('Error populating database: $e');
  }
}

// This function can be called from the main app or run as a standalone script
Future<void> main() async {
  await populateDatabase();
}

