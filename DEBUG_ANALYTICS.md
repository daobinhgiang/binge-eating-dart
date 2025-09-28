# 🔍 Firebase Analytics Debugging Guide

## 🚨 **Common Reasons Why Events Don't Appear**

### **1. Firebase Project Configuration Issues**
- Wrong Firebase project selected
- Analytics not enabled for the project
- Incorrect app configuration

### **2. App Configuration Issues**
- Missing or incorrect `google-services.json` (Android)
- Missing or incorrect `GoogleService-Info.plist` (iOS)
- Environment variables not loaded properly

### **3. Analytics Collection Issues**
- Analytics collection disabled
- Debug mode not enabled
- Events not being sent due to network issues

### **4. Timing Issues**
- Events can take 1-24 hours to appear in Firebase Console
- Real-time events may not show immediately
- Debug events appear faster than production events

## 🔧 **Step-by-Step Debugging**

### **Step 1: Verify Firebase Project Setup**

1. **Check Firebase Console Access**
   - Go to https://console.firebase.google.com/
   - Verify you can see your project: `bed-app-ef8f8`
   - Check if Analytics is enabled (should see "Analytics" in left sidebar)

2. **Verify App Configuration**
   ```bash
   # Check if google-services.json exists
   ls -la android/app/google-services.json
   
   # Check if GoogleService-Info.plist exists (iOS)
   ls -la ios/Runner/GoogleService-Info.plist
   ```

### **Step 2: Enable Debug Mode**

Add this to your `main.dart` to enable debug mode:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable debug mode for analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  runApp(const ProviderScope(child: BEDApp()));
}
```

### **Step 3: Test Analytics with Debug Logs**

Create a simple test to verify analytics are working:

```dart
// Add this to your home screen for testing
void _testAnalytics() async {
  try {
    final analytics = FirebaseAnalytics.instance;
    
    // Test basic event
    await analytics.logEvent(
      name: 'test_event',
      parameters: {
        'test_param': 'test_value',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    print('✅ Test event sent successfully');
  } catch (e) {
    print('❌ Error sending test event: $e');
  }
}
```

### **Step 4: Check Network and Permissions**

1. **Android Permissions** (android/app/src/main/AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

2. **iOS Permissions** (ios/Runner/Info.plist):
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
   </dict>
   ```

### **Step 5: Verify Environment Variables**

Check if your `.env` file has the correct Firebase configuration:

```bash
# Check your .env file
cat .env | grep FIREBASE
```

Should include:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_APP_ID_ANDROID`
- `FIREBASE_APP_ID_IOS`
- `FIREBASE_MESSAGING_SENDER_ID`

## 🧪 **Quick Test Script**

Run this test to verify analytics are working:

```dart
// test_analytics_simple.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final analytics = FirebaseAnalytics.instance;
  
  print('🧪 Testing Firebase Analytics...');
  
  try {
    await analytics.logEvent(
      name: 'debug_test_event',
      parameters: {
        'test': 'success',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    print('✅ Event sent successfully');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

## 📊 **Where to Look for Events**

### **Firebase Console**
1. Go to https://console.firebase.google.com/
2. Select your project
3. Navigate to **Analytics** → **Events**
4. Look for:
   - `debug_test_event`
   - `urge_relapse_button_clicked`
   - `urge_help_dialog_interaction`

### **Real-time Events**
1. Go to **Analytics** → **Real-time**
2. Should show live events as they happen
3. Debug events appear within minutes

### **Debug View (Android)**
1. Enable debug mode in Firebase Console
2. Use `adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE_NAME`
3. Check logs with `adb logcat | grep FirebaseAnalytics`

## ⏰ **Timing Expectations**

- **Debug events**: 1-5 minutes
- **Production events**: 1-24 hours
- **Real-time view**: 1-10 minutes
- **Standard reports**: 24-48 hours

## 🚨 **Troubleshooting Checklist**

- [ ] Firebase project exists and is accessible
- [ ] Analytics is enabled in Firebase Console
- [ ] App is properly configured with correct files
- [ ] Environment variables are loaded
- [ ] Network connection is working
- [ ] App has internet permissions
- [ ] Debug mode is enabled
- [ ] Events are being sent (check console logs)
- [ ] Waiting appropriate time for events to appear

## 📞 **Next Steps if Still Not Working**

1. **Check Firebase Console** for any error messages
2. **Verify project ID** matches your configuration
3. **Test with a simple event** first
4. **Check network connectivity**
5. **Verify app is properly signed** (for production)
6. **Contact Firebase support** if all else fails

## 🔍 **Debug Commands**

```bash
# Check if app is running
flutter devices

# Run with debug logs
flutter run --debug

# Check Firebase configuration
flutter packages get

# Verify environment variables
flutter run --dart-define-from-file=.env
```
