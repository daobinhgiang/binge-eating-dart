import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/services/lesson_service.dart';

/// Utility class to initialize Firebase data
class FirebaseDataInitializer {
  static Future<void> initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> initializeLessons() async {
    try {
      await initializeApp();
      // Lesson initialization removed - using new Stage system
      print('✅ Firebase initialized successfully!');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }
}

/// Main function to run the initialization
/// This can be called from a separate script or from the main app
Future<void> main() async {
  await FirebaseDataInitializer.initializeLessons();
}
