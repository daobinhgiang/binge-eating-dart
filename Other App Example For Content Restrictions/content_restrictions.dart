import 'package:flutter/material.dart';
import 'package:dasimba/services/screen_time_service.dart';
import 'package:dasimba/services/user_data_service.dart';
import 'dart:async';

class ContentRestrictionsScreen extends StatefulWidget {
  const ContentRestrictionsScreen({super.key});

  @override
  State<ContentRestrictionsScreen> createState() => _ContentRestrictionsScreenState();
}

class _ContentRestrictionsScreenState extends State<ContentRestrictionsScreen> {
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
        if (websites.isEmpty) {
          // Add default website to block if no websites are stored
          _blockedWebsites = ['tiktok.com'];
          // Save default to Firestore
          await _userDataService.saveBlockedWebsites(_blockedWebsites);
        } else {
          setState(() {
            _blockedWebsites = websites;
            _isInitializing = false;
          });
        }
      }
    } catch (e) {
      print('Error initializing blocked websites: $e');
      // Add default website if there's an error
      setState(() {
        _blockedWebsites = ['tiktok.com'];
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
          _message = 'Websites blocked successfully';
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
    final website = _websiteController.text.trim();
    if (website.isNotEmpty && !_blockedWebsites.contains(website)) {
      setState(() {
        _blockedWebsites.add(website);
        _websiteController.clear();
      });
      
      // Save the updated list to Firebase
      _userDataService.saveBlockedWebsites(_blockedWebsites);
    }
  }

  void _removeWebsite(String website) {
    setState(() {
      _blockedWebsites.remove(website);
    });
    
    // Save the updated list to Firebase
    _userDataService.saveBlockedWebsites(_blockedWebsites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Content Restrictions', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: _isInitializing
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with emoji and title
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '🛡️',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Block Distractions',
                                  style: TextStyle(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Keep your focus by blocking time-wasting sites',
                                  style: TextStyle(
                                    fontSize: 14, 
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Input field with modern styling
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _websiteController,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add website to block...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.web, color: Color(0xFF2196F3)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
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
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                    const SizedBox(height: 20),
                    
                    // Websites list header
                    Row(
                      children: [
                        const Text(
                          'Websites to Block',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
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
                            children: const [
                              Icon(
                                Icons.web_asset_off,
                                size: 60,
                                color: Color(0xFFBDBDBD),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No websites added yet',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 16,
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
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFFE3F2FD),
                                  radius: 18,
                                  child: Icon(
                                    Icons.block, 
                                    color: Color(0xFF2196F3),
                                    size: 16,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(
                                  website,
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFF757575),
                                  ),
                                  onPressed: () => _removeWebsite(website),
                                ),
                              ),
                            );
                          },
                        ),
                    ),
                    
                    // Message display
                    if (_message.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _message.startsWith('Error') 
                            ? Colors.red.withOpacity(0.1) 
                            : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _message.startsWith('Error') 
                              ? Colors.red.withOpacity(0.3) 
                              : Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _message.startsWith('Error') ? Icons.error_outline : Icons.check_circle_outline,
                              color: _message.startsWith('Error') ? Colors.red[300] : Colors.green[300],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _message,
                                style: TextStyle(
                                  color: _message.startsWith('Error') ? Colors.red[300] : Colors.green[300],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Block websites button
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
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
                                      'Block Websites',
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
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
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
                              'On iOS, website blocking requires Content Restrictions to be enabled in Screen Time settings.',
                              style: TextStyle(
                                color: Colors.amber[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 