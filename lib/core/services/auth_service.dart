import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user_model.dart';
import 'auto_todo_service.dart';
import 'fcm_token_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AutoTodoService _autoTodoService = AutoTodoService();
  final FCMTokenService _fcmTokenService = FCMTokenService();
  
  // Configure GoogleSignIn with platform-specific client IDs
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] 
        : null, // For mobile platforms, client ID is handled by platform configuration
  );

  // Current user stream
  Stream<UserModel?> get currentUserStream {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  // Get current user
  Future<UserModel?> get currentUser async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirebaseUser(firebaseUser);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
        // Initialize FCM token for the user
        await _fcmTokenService.initializeForUser(credential.user!.uid);
        return await _getUserFromFirebaseUser(credential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());
            
        // Initialize todos for the new user
        await _autoTodoService.initializeUserTodos(credential.user!.uid);
        
        // Initialize FCM token for the new user
        await _fcmTokenService.initializeForUser(credential.user!.uid);

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-in...');
      
      // Try silent sign-in first (recommended for web)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, try interactive sign-in
      if (googleUser == null) {
        print('Silent sign-in failed, trying interactive sign-in...');
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        print('User cancelled Google Sign-in');
        // User cancelled the sign-in
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google auth details obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Firebase credential created');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase authentication successful: ${userCredential.user?.uid}');
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore, if not create them
        print('Checking if user exists in Firestore...');
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          
        if (!userDoc.exists) {
          print('User does not exist, creating new user...');
          // Extract name parts from display name
          final displayName = userCredential.user!.displayName ?? '';
          print('Display name: $displayName');
          final nameParts = displayName.split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          print('Creating user with firstName: $firstName, lastName: $lastName');

          // Create new user with default role as patient
          final userModel = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            firstName: firstName,
            lastName: lastName,
            role: UserRole.patient, // Default role for Google sign-in
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            photoUrl: userCredential.user!.photoURL,
          );

          print('Saving user to Firestore...');
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toFirestore());
          print('User saved to Firestore successfully');
          
          // Initialize todos for the new user
          await _autoTodoService.initializeUserTodos(userCredential.user!.uid);
          print('Auto todos initialized for new user');
          
          // Initialize FCM token for the new user
          await _fcmTokenService.initializeForUser(userCredential.user!.uid);
          print('FCM token initialized for new user');
        } else {
          print('User exists, updating last login...');
          // Update last login time for existing user
          await _updateLastLogin(userCredential.user!.uid);
          
          // Initialize FCM token for existing user
          await _fcmTokenService.initializeForUser(userCredential.user!.uid);
          print('FCM token initialized for existing user');
        }

        print('Retrieving user from Firestore...');
        final user = await _getUserFromFirebaseUser(userCredential.user!);
        print('User retrieved: ${user?.email}');
        return user;
      }
      print('No user in credential');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('Google Sign-in Error: $e');
      print('Stack trace: $stackTrace');
      throw 'Google sign-in failed. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Clean up FCM token
        await _fcmTokenService.cleanupForUser(currentUser.uid);
      }
      
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Check if user is already signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    try {
      final user = await _googleSignIn.signInSilently();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      final userDoc = _firestore.collection('users').doc(user.uid);
      final updateData = <String, dynamic>{};

      if (firstName != null) updateData['firstName'] = firstName.trim();
      if (lastName != null) updateData['lastName'] = lastName.trim();
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      if (updateData.isNotEmpty) {
        await userDoc.update(updateData);
      }
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Update onboarding status
  Future<void> updateOnboardingStatus({
    bool? onboardingCompleted,
    bool? onboardingPartiallyCompleted,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      final userDoc = _firestore.collection('users').doc(user.uid);
      final updateData = <String, dynamic>{};

      if (onboardingCompleted != null) updateData['onboardingCompleted'] = onboardingCompleted;
      if (onboardingPartiallyCompleted != null) updateData['onboardingPartiallyCompleted'] = onboardingPartiallyCompleted;

      if (updateData.isNotEmpty) {
        await userDoc.update(updateData);
      }
    } catch (e) {
      throw 'Failed to update onboarding status. Please try again.';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Helper method to get user from Firebase user
  Future<UserModel?> _getUserFromFirebaseUser(User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper method to update last login time
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Silently fail for last login update
    }
  }

  // Helper method to handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please check your email and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
