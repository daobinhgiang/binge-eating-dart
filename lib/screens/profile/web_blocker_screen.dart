import 'package:flutter/material.dart';
import 'package:binge_eating_recovery/core/services/screen_time_service.dart';
import 'package:binge_eating_recovery/core/services/user_data_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:io';

class WebBlockerScreen extends StatefulWidget {
  const WebBlockerScreen({super.key});

  @override
  State<WebBlockerScreen> createState() => _WebBlockerScreenState();
}

class _WebBlockerScreenState extends State<WebBlockerScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final UserDataService _userDataService = UserDataService();
  bool _isLoading = false;
  bool _isInitializing = true;
  String _message = '';
  final TextEditingController _websiteController = TextEditingController();
  List<String> _blockedWebsites = [];
  StreamSubscription? _blockedWebsitesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBlockedWebsites();
  }

  Future<void> _initializeBlockedWebsites() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      // Subscribe to the stream of blocked websites for real-time updates
      _blockedWebsitesSubscription = _userDataService.blockedWebsitesStream().listen((websites) {
        setState(() {
          _blockedWebsites = websites;
          _isInitializing = false;
        });
      });
      
      // If stream is empty initially, fetch websites from Firestore
      if (_blockedWebsites.isEmpty) {
        final websites = await _userDataService.getBlockedWebsites();
        setState(() {
          _blockedWebsites = websites;
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error initializing blocked websites: $e');
      setState(() {
        _blockedWebsites = [];
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _blockedWebsitesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _blockWebsites() async {
    if (!Platform.isIOS) {
      setState(() {
        _message = 'Error: Website blocking is only available on iOS';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // First save to Firebase
      final firebaseSaved = await _userDataService.saveBlockedWebsites(_blockedWebsites);
      
      // Then use the system's screen time API to block websites
      final systemBlocked = await _screenTimeService.blockWebsites(_blockedWebsites);
      
      setState(() {
        if (firebaseSaved && systemBlocked) {
          _message = 'Websites blocked successfully! Restrictions are now active.';
        } else if (firebaseSaved) {
          _message = 'Websites saved but could not be applied to system settings';
        } else {
          _message = 'Failed to block websites';
        }
      });
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

  void _addWebsite() {
    final website = _websiteController.text.trim().toLowerCase();
    if (website.isEmpty) {
      setState(() {
        _message = 'Error: Please enter a website URL';
      });
      return;
    }
    
    // Remove http://, https://, and www. prefixes
    String cleanedWebsite = website
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '');
    
    if (_blockedWebsites.contains(cleanedWebsite)) {
      setState(() {
        _message = 'Error: This website is already in the list';
      });
      return;
    }
    
    setState(() {
      _blockedWebsites.add(cleanedWebsite);
      _websiteController.clear();
      _message = '';
    });
    
    // Save the updated list to Firebase
    _userDataService.saveBlockedWebsites(_blockedWebsites);
  }

  void _removeWebsite(String website) {
    setState(() {
      _blockedWebsites.remove(website);
      _message = '';
    });
    
    // Save the updated list to Firebase
    _userDataService.saveBlockedWebsites(_blockedWebsites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text(
          'Website Blocker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF2D5016),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50)),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.web,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Block Websites',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _websiteController,
                            style: const TextStyle(
                              color: Color(0xFF2D5016),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter website (e.g., tiktok.com)',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              prefixIcon: const Icon(
                                Icons.language,
                                color: Color(0xFF4CAF50),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (_) => _addWebsite(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _addWebsite,
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Message display (moved before the list)
                  if (_message.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _message.startsWith('Error') 
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _message.startsWith('Error') 
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _message.startsWith('Error') 
                              ? Icons.error_outline 
                              : Icons.check_circle_outline,
                            color: _message.startsWith('Error') 
                              ? Colors.red[700]
                              : Colors.green[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _message.startsWith('Error') 
                                  ? Colors.red[700]
                                  : Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: _message.isNotEmpty ? 0 : 20),
                  
                  // Websites list header
                  Row(
                    children: [
                      const Text(
                        'Blocked Websites',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5016),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_blockedWebsites.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Websites list
                  Expanded(
                    child: _blockedWebsites.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.web_asset_off,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No websites added yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add websites above to start blocking',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _blockedWebsites.length,
                        itemBuilder: (context, index) {
                          final website = _blockedWebsites[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.block,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              title: Text(
                                website,
                                style: const TextStyle(
                                  color: Color(0xFF2D5016),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red[400],
                                ),
                                onPressed: () => _removeWebsite(website),
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Block websites button
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading ? null : _blockWebsites,
                        child: Center(
                          child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.shield,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Apply Website Blocks',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ),
                  
                  // iOS notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Website blocking requires iOS 16+ and Content Restrictions to be enabled in Screen Time settings.',
                            style: TextStyle(
                              color: Colors.amber[800],
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

