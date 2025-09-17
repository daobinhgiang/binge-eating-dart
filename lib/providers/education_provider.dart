import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final articlesProvider = StreamProvider<List<Article>>((ref) {
  // Check if user is authenticated
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) {
    return Stream.value(<Article>[]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .handleError((error) {
        print('❌ Education Provider Error (articlesProvider): $error');
        // Return empty list instead of throwing error to prevent app crash
        return Stream.value(<Article>[]);
      })
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Article.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

final articleProvider = StreamProvider.family<Article?, String>((ref, articleId) {
  // Check if user is authenticated
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) {
    return Stream.value(null);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .doc(articleId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return Article.fromMap(snapshot.data()!, snapshot.id);
  });
});

final featuredArticlesProvider = StreamProvider<List<Article>>((ref) {
  // Check if user is authenticated
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) {
    return Stream.value(<Article>[]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .where('isFeatured', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .limit(5)
      .snapshots()
      .handleError((error) {
        print('❌ Education Provider Error (featuredArticlesProvider): $error');
        throw error;
      })
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Article.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

final articlesByCategoryProvider = StreamProvider.family<List<Article>, String>((ref, category) {
  // Check if user is authenticated
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) {
    return Stream.value(<Article>[]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .where('category', isEqualTo: category)
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .handleError((error) {
        print('❌ Education Provider Error (articlesByCategoryProvider): $error');
        throw error;
      })
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Article.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

class EducationNotifier extends StateNotifier<AsyncValue<void>> {
  EducationNotifier(this._firestore) : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore;

  Future<void> addArticle(Article article) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('articles').add(article.toMap());
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('❌ Education Notifier Error (addArticle): $e');
      print('🔗  ');
      print('   https://console.firebase.google.com/v1/r/project/bed-app-ef8f8/firestore/indexes');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateArticle(String articleId, Article article) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('articles').doc(articleId).update(article.toMap());
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('❌ Education Notifier Error (updateArticle): $e');
      print('🔗  ');
      print('   https://console.firebase.google.com/v1/r/project/bed-app-ef8f8/firestore/indexes');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteArticle(String articleId) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('articles').doc(articleId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('❌ Education Notifier Error (deleteArticle): $e');
      print('🔗  ');
      print('   https://console.firebase.google.com/v1/r/project/bed-app-ef8f8/firestore/indexes');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final educationNotifierProvider = StateNotifierProvider<EducationNotifier, AsyncValue<void>>((ref) {
  return EducationNotifier(ref.watch(firestoreProvider));
});

