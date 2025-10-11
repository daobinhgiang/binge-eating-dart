import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/exp_service.dart';
import '../models/exp_ledger.dart';
import '../models/quiz_submission.dart';
import 'auth_provider.dart';

// EXP service provider
final expServiceProvider = Provider<ExpService>((ref) => ExpService());

// Current user's EXP and level provider (from auth)
final userExpProvider = Provider<({int exp, int level})?>((ref) {
  final user = ref.watch(currentUserDataProvider);
  if (user == null) return null;
  
  return (exp: user.exp, level: user.level);
});

// EXP history provider
final expHistoryProvider = StreamProvider.family<List<ExpLedger>, int>((ref, limit) {
  final service = ref.watch(expServiceProvider);
  return service.streamExpHistory(limit: limit);
});

// Completed quizzes count provider
final completedQuizzesCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(expServiceProvider);
  return await service.getCompletedQuizzesCount();
});

// Current level progress provider
final levelProgressProvider = Provider<double>((ref) {
  final userExp = ref.watch(userExpProvider);
  if (userExp == null) return 0.0;
  
  final service = ref.read(expServiceProvider);
  return service.getCurrentLevelProgress(userExp.exp, userExp.level);
});

// EXP remaining for next level provider
final expRemainingProvider = Provider<int>((ref) {
  final userExp = ref.watch(userExpProvider);
  if (userExp == null) return 0;
  
  final service = ref.read(expServiceProvider);
  return service.getExpRemainingForNextLevel(userExp.exp, userExp.level);
});

// Quiz completion check provider
final isQuizCompletedProvider = FutureProvider.family<bool, String>((ref, quizId) async {
  final service = ref.read(expServiceProvider);
  return await service.isQuizCompleted(quizId);
});

// State notifier for quiz submission
class QuizSubmissionNotifier extends StateNotifier<AsyncValue<QuizSubmissionState?>> {
  QuizSubmissionNotifier(this._expService) : super(const AsyncValue.data(null));

  final ExpService _expService;
  StreamSubscription<QuizSubmission>? _submissionSubscription;

  Future<void> submitQuiz(String quizId, Map<String, int> answers) async {
    state = const AsyncValue.loading();

    try {
      final submissionRef = await _expService.submitQuizForValidation(quizId, answers);
      
      if (submissionRef == null) {
        state = AsyncValue.error(
          'Failed to submit quiz or quiz already completed',
          StackTrace.current,
        );
        return;
      }

      // Listen to submission result
      _submissionSubscription?.cancel();
      _submissionSubscription = _expService
          .listenToSubmissionResult(submissionRef.id)
          .listen((submission) {
        if (submission.status == SubmissionStatus.validated) {
          state = AsyncValue.data(QuizSubmissionState(
            submission: submission,
            completed: true,
          ));
          _submissionSubscription?.cancel();
        } else if (submission.status == SubmissionStatus.failed) {
          state = AsyncValue.error(
            'Quiz validation failed',
            StackTrace.current,
          );
          _submissionSubscription?.cancel();
        } else {
          // Still pending
          state = AsyncValue.data(QuizSubmissionState(
            submission: submission,
            completed: false,
          ));
        }
      }, onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
        _submissionSubscription?.cancel();
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    _submissionSubscription?.cancel();
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _submissionSubscription?.cancel();
    super.dispose();
  }
}

class QuizSubmissionState {
  final QuizSubmission submission;
  final bool completed;

  QuizSubmissionState({
    required this.submission,
    required this.completed,
  });
}

// Quiz submission notifier provider
final quizSubmissionProvider = StateNotifierProvider<QuizSubmissionNotifier, AsyncValue<QuizSubmissionState?>>((ref) {
  return QuizSubmissionNotifier(ref.watch(expServiceProvider));
});

