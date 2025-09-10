import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart' as app_user;

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authProvider).authStateChanges();
});

final userProvider = StreamProvider<app_user.User?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      
      return ref.watch(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        return app_user.User.fromMap(snapshot.data()!, snapshot.id);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._auth, this._firestore) : super(const AsyncValue.data(null));

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _createUserIfNotExists(credential.user!);
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
  ) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await _createUserIfNotExists(credential.user!);
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> _createUserIfNotExists(User firebaseUser) async {
    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    
    if (!userDoc.exists) {
      final user = app_user.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());
    } else {
      // Update last login time
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  );
});

