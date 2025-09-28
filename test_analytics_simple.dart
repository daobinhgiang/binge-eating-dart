// Simple test to verify Firebase Analytics is working
// Run with: dart test_analytics_simple.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('🧪 Starting Firebase Analytics Test...');
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
    
    // Get analytics instance
    final analytics = FirebaseAnalytics.instance;
    print('✅ Analytics instance created');
    
    // Enable analytics collection
    await analytics.setAnalyticsCollectionEnabled(true);
    print('✅ Analytics collection enabled');
    
    // Send a test event
    await analytics.logEvent(
      name: 'debug_test_event',
      parameters: {
        'test_param': 'test_value',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'debug_script',
      },
    );
    print('✅ Test event sent successfully');
    
    // Send the urge relapse button event
    await analytics.logEvent(
      name: 'urge_relapse_button_clicked',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'user_id': 'test_user',
        'button_location': 'home_screen',
        'button_text': 'I have an urge to relapse',
        'critical_feature': 'true',
      },
    );
    print('✅ Urge relapse button event sent');
    
    print('🎉 All tests completed successfully!');
    print('📊 Check Firebase Console in 5-10 minutes for events:');
    print('   - debug_test_event');
    print('   - urge_relapse_button_clicked');
    
  } catch (e) {
    print('❌ Error during test: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
