# App and Website Blocker Setup Guide

This document describes the implementation of App Blocker and Website Blocker features using iOS Screen Time API.

## Implementation Overview

### Flutter Side (Dart)

1. **Services Created:**
   - `lib/core/services/screen_time_service.dart` - Method channel communication with iOS
   - `lib/core/services/user_data_service.dart` - Firebase storage for blocked websites

2. **Screens Created:**
   - `lib/screens/profile/app_blocker_screen.dart` - App blocking interface
   - `lib/screens/profile/web_blocker_screen.dart` - Website blocking interface

3. **Navigation:**
   - Added routes in `lib/main.dart`:
     - `/profile/app-blocker`
     - `/profile/web-blocker`
   - Added menu items in `lib/screens/profile/profile_screen.dart`

### iOS Side (Swift)

1. **Updated Files:**
   - `ios/Runner/AppDelegate.swift` - Added Screen Time method channels and implementation
   - `ios/Runner/Info.plist` - Added NSFamilyActivityReportingDescription permission
   - `ios/Runner/Runner.entitlements` - Added com.apple.developer.family-controls capability
   - `ios/Podfile` - Updated minimum iOS version to 15.0

## Xcode Configuration Steps

To complete the setup, you need to add the required frameworks in Xcode:

### 1. Open Xcode Project
```bash
cd ios
open Runner.xcworkspace
```

### 2. Add Frameworks
1. Select the **Runner** project in the Project Navigator
2. Select the **Runner** target
3. Go to the **Build Phases** tab
4. Expand **Link Binary With Libraries**
5. Click the **+** button
6. Search for and add the following frameworks:
   - **FamilyControls.framework**
   - **DeviceActivity.framework**
   - **ManagedSettings.framework**

### 3. Verify Capabilities
1. Go to the **Signing & Capabilities** tab
2. Ensure **Family Controls** capability is enabled
   - If not visible, click **+ Capability** and add **Family Controls**

### 4. Update Deployment Target
1. In the **General** tab, set **Minimum Deployments** to **iOS 16.0** or higher
2. This is required for FamilyControls `requestAuthorization` method support

### 5. Clean and Rebuild
```bash
flutter clean
cd ios
pod install
cd ..
flutter pub get
flutter run
```

## How It Works

### App Blocker
- Uses `FamilyActivityPicker` to let users select apps
- Uses `ManagedSettingsStore.shield.applications` to block selected apps
- Requires iOS 16.0+
- User authorization is requested automatically

### Website Blocker
- Stores blocked websites in Firebase Firestore
- Uses `ManagedSettingsStore.webContent.blockedByFilter` to block domains
- Supports adding/removing websites dynamically
- Real-time sync with Firebase

## Firebase Structure

Blocked websites are stored in Firestore:
```
users/{userId}/settings/content_restrictions/
├── blocked_websites: ["tiktok.com", "instagram.com"]
└── updated_at: timestamp
```

## Required Permissions

From Info.plist:
- **NSFamilyActivityReportingDescription**: "This app helps you manage screen time by allowing you to restrict access to specific apps and websites."

From Runner.entitlements:
- **com.apple.developer.family-controls**: true

## Testing

1. Run the app on a physical iOS device (iOS 16+)
2. Navigate to You tab → App Blocker or Website Blocker
3. For App Blocker:
   - Tap "Select Apps to Block"
   - Choose apps from the system picker
   - Apps will be restricted with Screen Time shield
4. For Website Blocker:
   - Add websites to the list
   - Tap "Apply Website Blocks"
   - Websites will be blocked in Safari and other browsers

## Important Notes

- **iOS Only**: These features only work on iOS 16+ devices
- **Physical Device Required**: Screen Time API doesn't work in simulator
- **Screen Time Settings**: Users may need to enable Screen Time in iOS Settings
- **Authorization**: App will request Screen Time authorization on first use
- **Persistence**: Website blocks are saved to Firebase and persist across sessions

## Troubleshooting

### Swift Compiler Errors about iOS availability
**Fixed!** The AppDelegate.swift has been updated with proper `@available(iOS 16.0, *)` annotations for authorization methods.

### App doesn't show Family Activity Picker
- Ensure device is running iOS 16+
- Check that Family Controls capability is enabled in Xcode
- Verify frameworks are properly linked

### Website blocking not working
- Ensure Screen Time is enabled in iOS Settings
- Check Content Restrictions settings in Screen Time
- Verify Firebase user authentication is working

### Build errors
- Clean project: `flutter clean && cd ios && pod install && cd ..`
- Verify minimum iOS version is 16.0 in all locations:
  - Podfile (already updated to 16.0)
  - Xcode project settings
  - Runner target deployment target

## Method Channel Details

Channel name: `com.bingeeating/screentime`

Methods:
- `showFamilyActivityPicker()` - Shows app selection UI
- `blockWebsites(websites: List<String>)` - Blocks specified websites

## References

- [Apple FamilyControls Documentation](https://developer.apple.com/documentation/familycontrols)
- [Screen Time API Overview](https://developer.apple.com/documentation/screentime)
- [ManagedSettings Framework](https://developer.apple.com/documentation/managedsettings)

