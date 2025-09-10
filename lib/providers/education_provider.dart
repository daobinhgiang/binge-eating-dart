import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final articlesProvider = StreamProvider<List<Article>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Article.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

final articleProvider = StreamProvider.family<Article?, String>((ref, articleId) {
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
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .where('isFeatured', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Article.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

final articlesByCategoryProvider = StreamProvider.family<List<Article>, String>((ref, category) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('articles')
      .where('category', isEqualTo: category)
      .orderBy('publishedAt', descending: true)
      .snapshots()
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
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateArticle(String articleId, Article article) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('articles').doc(articleId).update(article.toMap());
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteArticle(String articleId) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('articles').doc(articleId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final educationNotifierProvider = StateNotifierProvider<EducationNotifier, AsyncValue<void>>((ref) {
  return EducationNotifier(ref.watch(firestoreProvider));
});

