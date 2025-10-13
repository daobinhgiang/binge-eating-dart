import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID or throw an exception if not logged in
  String _getUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  // Save blocked websites to Firebase
  Future<bool> saveBlockedWebsites(List<String> websites) async {
    try {
      final userId = _getUserId();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('content_restrictions')
          .set({
            'blocked_websites': websites,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving blocked websites: $e');
      return false;
    }
  }

  // Get blocked websites from Firebase
  Future<List<String>> getBlockedWebsites() async {
    try {
      final userId = _getUserId();
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('content_restrictions')
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        return List<String>.from(data?['blocked_websites'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting blocked websites: $e');
      return [];
    }
  }

  // Get a stream of blocked websites for real-time updates
  Stream<List<String>> blockedWebsitesStream() {
    try {
      final userId = _getUserId();
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('content_restrictions')
          .snapshots()
          .map((doc) {
            if (doc.exists) {
              final data = doc.data();
              return List<String>.from(data?['blocked_websites'] ?? []);
            }
            return <String>[];
          });
    } catch (e) {
      print('Error getting blocked websites stream: $e');
      // Return an empty stream
      return Stream.value(<String>[]);
    }
  }
}

