import 'package:flutter/material.dart';
import 'package:dasimba/services/screen_time_service.dart';
import 'dart:io';
import 'package:dasimba/analytics.dart';

class AppRestrictionsScreen extends StatefulWidget {
  const AppRestrictionsScreen({super.key});

  @override
  State<AppRestrictionsScreen> createState() => _AppRestrictionsScreenState();
}

class _AppRestrictionsScreenState extends State<AppRestrictionsScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  bool _isLoading = false;
  String _message = '';
  bool _hasLoggedScreenView = false;

  @override
  Widget build(BuildContext context) {
    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoggedScreenView) {
        Analytics.logScreenView(screenName: 'App Restrictions');
        _hasLoggedScreenView = true;
      }
    });

    if (!Platform.isIOS) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'App Restrictions are only available on iOS devices.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.app_blocking,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Limit Distracting Apps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Uses iOS Screen Time to set app limits',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Use iOS Screen Time to select which apps to limit or block. This helps you stay focused by reducing distractions.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Select apps you find distracting\n• iOS will limit your time on these apps\n• Works with system Screen Time settings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _message.contains('Error') 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _message.contains('Error') 
                            ? Colors.red[300] 
                            : Colors.green[300],
                        fontSize: 14,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showAppRestrictions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Select Apps to Limit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Apple Screen Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'This feature uses the built-in iOS Screen Time API to help you manage your device usage. You can also configure Screen Time settings directly in iOS Settings:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Open the Settings app\n2. Tap on "Screen Time"\n3. Configure app limits, downtime, and content restrictions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppRestrictions() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await _screenTimeService.showFamilyActivityPicker();
      setState(() {
        _message = result 
            ? 'App restrictions applied successfully' 
            : 'No app restrictions were set';
      });

      // Log the action
      Analytics.logUserInteraction(
        action: 'set_app_restrictions',
        itemName: 'iOS Screen Time',
        itemCategory: 'app_management',
      );
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 