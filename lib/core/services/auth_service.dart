import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user_model.dart';
import 'fcm_token_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FCMTokenService _fcmTokenService = FCMTokenService();
  
  // Configure GoogleSignIn with platform-specific client IDs
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] 
        : null, // For mobile platforms, client ID is handled by platform configuration
  );

  // Current user stream
  Stream<UserModel?> get currentUserStream {
    return _auth.authStateChanges().asyncExpand((User? firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }
      
      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((doc) {
            if (doc.exists) {
              return UserModel.fromFirestore(doc);
            }
            return null;
          })
          .handleError((error) {
            print('Error streaming user data: $error');
            return null;
          });
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

        // Convert to Firestore and add additional fields for quest/lesson tracking
        final userData = userModel.toFirestore();
        
        // Explicitly initialize lesson progress fields to 0
        // These fields are used by LessonProgressService for daily quest tracking
        userData['lessonsCompletedToday'] = 0;
        userData['lessonsCompletedThisWeek'] = 0;
        userData['lastLessonCompletionDate'] = null;
        userData['lastLessonCompletionWeek'] = null;

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);
        
        print('✅ User created with initialized lesson progress fields');
        
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
  // Platform-specific behavior:
  // - Web: Closing the popup throws "popup_closed" exception
  // - Mobile (iOS/Android): Canceling returns null
  Future<UserModel?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-in...');
      
      // Try silent sign-in first (recommended for web)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, try interactive sign-in
      if (googleUser == null) {
        print('Silent sign-in failed, trying interactive sign-in...');
        try {
          googleUser = await _googleSignIn.signIn();
        } catch (signInError) {
          // On web, closing the popup throws an error with "popup_closed" message
          // On mobile, canceling returns null instead of throwing
          // Treat popup_closed as a cancellation, not an error
          if (signInError.toString().contains('popup_closed')) {
            print('User closed the sign-in popup');
            try {
              await _googleSignIn.disconnect();
            } catch (disconnectError) {
              print('Error disconnecting after popup closed: $disconnectError');
            }
            return null;
          }
          // If it's a different error, rethrow it
          rethrow;
        }
      }
      
      if (googleUser == null) {
        print('User cancelled Google Sign-in');
        // User cancelled the sign-in - disconnect to reset state
        try {
          await _googleSignIn.disconnect();
        } catch (disconnectError) {
          print('Error disconnecting after cancellation: $disconnectError');
        }
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
          
          // Convert to Firestore and add additional fields for quest/lesson tracking
          final userData = userModel.toFirestore();
          
          // Explicitly initialize lesson progress fields to 0
          userData['lessonsCompletedToday'] = 0;
          userData['lessonsCompletedThisWeek'] = 0;
          userData['lastLessonCompletionDate'] = null;
          userData['lastLessonCompletionWeek'] = null;
          
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);
          print('User saved to Firestore successfully with initialized lesson progress');
          
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
      // Disconnect to reset state on error
      try {
        await _googleSignIn.disconnect();
      } catch (disconnectError) {
        print('Error disconnecting after Firebase auth error: $disconnectError');
      }
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('Google Sign-in Error: $e');
      print('Stack trace: $stackTrace');
      
      // Provide more specific error messages
      if (e.toString().contains('sign_in_failed')) {
        throw 'Google Sign-In failed. This is likely due to SHA-1 fingerprint mismatch. Please contact support.';
      } else if (e.toString().contains('network_error')) {
        throw 'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('sign_in_canceled')) {
        throw 'Sign-in was cancelled. Please try again.';
      } else {
        throw 'Google sign-in failed. Please try again.';
      }
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

  // Sign in with Apple
  Future<UserModel?> signInWithApple() async {
    try {
      print('Starting Apple Sign-in...');
      
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      
      final userCredential = await _auth.signInWithProvider(appleProvider);
      print('Apple authentication successful: ${userCredential.user?.uid}');
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        print('Checking if user exists in Firestore...');
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          
        if (!userDoc.exists) {
          print('User does not exist, creating new user...');
          // Extract name parts from display name or additional user info
          final displayName = userCredential.user!.displayName ?? '';
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
            role: UserRole.patient, // Default role for Apple sign-in
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            photoUrl: userCredential.user!.photoURL,
          );

          print('Saving user to Firestore...');
          
          // Convert to Firestore and add additional fields for quest/lesson tracking
          final userData = userModel.toFirestore();
          
          // Explicitly initialize lesson progress fields to 0
          userData['lessonsCompletedToday'] = 0;
          userData['lessonsCompletedThisWeek'] = 0;
          userData['lastLessonCompletionDate'] = null;
          userData['lastLessonCompletionWeek'] = null;
          
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);
          print('User saved to Firestore successfully with initialized lesson progress');
          
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
      print('Apple Sign-in Error: $e');
      print('Stack trace: $stackTrace');
      throw 'Apple sign-in failed. Please try again.';
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

  // Update intro status
  Future<void> updateIntroStatus({required bool hasSeenIntro}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.update({'hasSeenIntro': hasSeenIntro});
    } catch (e) {
      throw 'Failed to update intro status. Please try again.';
    }
  }

  // Update tutorial status
  Future<void> updateTutorialStatus({
    bool? hasSeenAppTutorial,
    bool? hasCompletedFirstLesson,
    bool? hasSeenExercisesTutorial,
    bool? hasSeenJournalTutorial,
    bool? hasLoggedWeightDuringTutorial,
    bool? hasSeenWeightDiaryTutorial,
    bool? hasVisitedWeightDiary,
    bool? hasSeenStreakTutorial,
    bool? hasSeenPlantGrowthTutorial,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      final userDoc = _firestore.collection('users').doc(user.uid);
      final updateData = <String, dynamic>{};

      if (hasSeenAppTutorial != null) updateData['hasSeenAppTutorial'] = hasSeenAppTutorial;
      if (hasCompletedFirstLesson != null) updateData['hasCompletedFirstLesson'] = hasCompletedFirstLesson;
      if (hasSeenExercisesTutorial != null) updateData['hasSeenExercisesTutorial'] = hasSeenExercisesTutorial;
      if (hasSeenJournalTutorial != null) updateData['hasSeenJournalTutorial'] = hasSeenJournalTutorial;
      if (hasLoggedWeightDuringTutorial != null) updateData['hasLoggedWeightDuringTutorial'] = hasLoggedWeightDuringTutorial;
      if (hasSeenWeightDiaryTutorial != null) updateData['hasSeenWeightDiaryTutorial'] = hasSeenWeightDiaryTutorial;
      if (hasVisitedWeightDiary != null) updateData['hasVisitedWeightDiary'] = hasVisitedWeightDiary;
      if (hasSeenStreakTutorial != null) updateData['hasSeenStreakTutorial'] = hasSeenStreakTutorial;
      if (hasSeenPlantGrowthTutorial != null) updateData['hasSeenPlantGrowthTutorial'] = hasSeenPlantGrowthTutorial;

      if (updateData.isNotEmpty) {
        await userDoc.update(updateData);
      }
    } catch (e) {
      throw 'Failed to update tutorial status. Please try again.';
    }
  }

  // Delete user account and all associated data
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      print('Starting account deletion for user: ${user.uid}');

      // Clean up FCM token before deletion
      try {
        await _fcmTokenService.cleanupForUser(user.uid);
        print('FCM token cleaned up');
      } catch (e) {
        print('Error cleaning up FCM token during account deletion: $e');
        // Continue with deletion even if FCM cleanup fails
      }

      // Delete all user data from Firestore
      // IMPORTANT: Deleting a document does NOT delete its subcollections in Firestore
      // We must manually delete all subcollections
      await _deleteAllUserData(user.uid);
      print('All user data deleted from Firestore');

      // Delete Firebase Auth user FIRST - while credentials are still valid
      // This must happen before disconnecting from Google Sign-In
      try {
        await user.delete();
        print('Firebase Auth user deleted');
      } catch (e) {
        print('Error deleting Firebase Auth user: $e');
        // Try to disconnect from Google anyway
        try {
          await _googleSignIn.disconnect();
          print('Google Sign-In disconnected');
        } catch (disconnectError) {
          print('Error disconnecting from Google after auth deletion failed: $disconnectError');
        }
        rethrow;
      }

      // Disconnect from Google Sign-In to clear all cached credentials
      // This must happen AFTER deleting the Firebase Auth user
      // Otherwise, the credentials won't be available for the deletion
      try {
        await _googleSignIn.disconnect();
        print('Google Sign-In disconnected');
      } catch (e) {
        print('Error disconnecting from Google during account deletion: $e');
        // Continue - Firebase user is already deleted
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Helper method to delete all user data including subcollections
  Future<void> _deleteAllUserData(String userId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // Delete todos subcollection
      await _deleteSubcollection(userDocRef, 'todos');

      // Delete regeneration logs subcollection
      // This is critical - if not deleted, recreating the account will use stale logs
      await _deleteSubcollection(userDocRef, 'regenerationLog');

      // Delete assessments subcollection
      await _deleteSubcollection(userDocRef, 'assessments');

      // Delete exercises subcollection
      await _deleteSubcollection(userDocRef, 'exercises');

      // Delete onboarding document (top-level collection)
      try {
        await _firestore.collection('onboarding').doc(userId).delete();
        print('Deleted onboarding document');
      } catch (e) {
        print('Error deleting onboarding document: $e');
        // Continue with other deletions
      }

      // Delete all week-based data
      // Get all weeks documents
      final weeksSnapshot = await userDocRef.collection('weeks').get();
      
      for (final weekDoc in weeksSnapshot.docs) {
        final weekRef = weekDoc.reference;
        
        // Delete all diary subcollections within each week
        await _deleteSubcollection(weekRef, 'foodDiaries');
        await _deleteSubcollection(weekRef, 'weightDiaries');
        await _deleteSubcollection(weekRef, 'moneyDiaries');
        await _deleteSubcollection(weekRef, 'bodyImageDiaries');
        await _deleteSubcollection(weekRef, 'thoughtDumps');
        
        // Delete the week document itself
        await weekRef.delete();
      }

      // Finally, delete the main user document
      // This will delete ALL fields including:
      // - User profile data (name, email, etc.)
      // - Lesson progress (lessonsCompletedToday, lessonsCompletedThisWeek, etc.)
      // - Quest regeneration tracking (lastSeedsGeneratedDate, lastGrowthWeek, etc.)
      // - Streak data (streak, lastStreakDate)
      // - Level and EXP data
      print('Deleting main user document (includes all user fields)...');
      await userDocRef.delete();
      print('✅ Main user document deleted with all fields');
    } catch (e) {
      print('Error deleting user data: $e');
      throw 'Failed to delete user data from database.';
    }
  }

  // Helper method to delete all documents in a subcollection
  Future<void> _deleteSubcollection(
    DocumentReference docRef,
    String subcollectionName,
  ) async {
    try {
      final snapshot = await docRef.collection(subcollectionName).get();
      
      // Delete in batches of 500 (Firestore batch limit)
      final batch = _firestore.batch();
      int count = 0;
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;
        
        // Commit batch if we reach 500 documents
        if (count >= 500) {
          await batch.commit();
          count = 0;
        }
      }
      
      // Commit any remaining deletions
      if (count > 0) {
        await batch.commit();
      }
      
      if (snapshot.docs.isNotEmpty) {
        print('Deleted ${snapshot.docs.length} documents from $subcollectionName');
      }
    } catch (e) {
      print('Error deleting subcollection $subcollectionName: $e');
      // Don't throw - continue with other deletions
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
    } catch (e, stackTrace) {
      print('ERROR in _getUserFromFirebaseUser: $e');
      print('Stack trace: $stackTrace');
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
        return 'Invalid credentials. This may be due to SHA-1 fingerprint mismatch.';
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
