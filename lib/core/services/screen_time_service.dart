import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenTimeService {
  static const MethodChannel _channel = MethodChannel('com.bingeeating/screentime');
  
  /// Shows the Family Activity Picker on iOS devices
  /// 
  /// Returns true if the picker was shown successfully,
  /// throws PlatformException if there was an error
  Future<bool> showFamilyActivityPicker() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'Screen Time API is only available on iOS',
      );
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('showFamilyActivityPicker');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to show Family Activity Picker: ${e.message}');
      rethrow;
    }
  }
  
  /// Blocks specific websites using iOS Screen Time API
  /// 
  /// [websites] - List of domain names to block (e.g. ["tiktok.com", "instagram.com"])
  /// Returns true if websites were blocked successfully,
  /// throws PlatformException if there was an error
  Future<bool> blockWebsites(List<String> websites) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'Screen Time API is only available on iOS',
      );
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'blockWebsites',
        {'websites': websites},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to block websites: ${e.message}');
      rethrow;
    }
  }
}

