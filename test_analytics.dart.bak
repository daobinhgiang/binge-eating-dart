// Test script to verify analytics integration
// Run this with: dart test_analytics.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/firebase_options.dart';
import 'lib/core/services/firebase_analytics_service.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Test analytics service
  final analyticsService = FirebaseAnalyticsService();
  
  print('🧪 Testing Analytics Integration...');
  
  try {
    // Test urge relapse button tracking
    await analyticsService.trackUrgeRelapseButtonUsage();
    print('✅ urge_relapse_button_clicked event sent');
    
    // Test dialog interaction tracking
    await analyticsService.trackUrgeHelpDialogInteraction('dialog_opened');
    print('✅ urge_help_dialog_interaction event sent');
    
    print('🎉 Analytics integration test completed successfully!');
    print('📊 Check your Firebase Console for the events in a few minutes.');
    
  } catch (e) {
    print('❌ Error testing analytics: $e');
  }
}
