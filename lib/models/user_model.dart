import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  patient,
  clinician,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.clinician:
        return 'Clinician';
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime? fcmTokenUpdatedAt;
  final Map<String, dynamic> preferences;
  final bool onboardingCompleted;
  final bool onboardingPartiallyCompleted;
  final bool hasSeenIntro;
  final bool hasSeenAppTutorial;
  final bool hasCompletedFirstLesson;
  final bool hasSeenExercisesTutorial;
  final bool hasSeenJournalTutorial;
  final bool hasLoggedWeightDuringTutorial;
  final bool hasSeenWeightDiaryTutorial;
  final bool hasVisitedWeightDiary;
  final bool hasSeenPlantGrowthTutorial;
  final bool hasSeenTimerClosingSlides;
  final int level;
  final int exp;
  final String? lastSeedsGeneratedDate; // YYYY-MM-DD format
  final int? lastGrowthWeek;            // ISO week number
  final int? lastGrowthYear;            // Year for growth tasks
  final DateTime? lastSeedsGeneratedAt; // Full timestamp
  final DateTime? lastGrowthTasksGeneratedAt; // Full timestamp
  final int streak;                      // Current streak count
  final DateTime? lastStreakDate;        // Date of last streak update

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.photoUrl,
    this.fcmToken,
    this.fcmTokenUpdatedAt,
    this.preferences = const {},
    this.onboardingCompleted = false,
    this.onboardingPartiallyCompleted = false,
    this.hasSeenIntro = false,
    this.hasSeenAppTutorial = false,
    this.hasCompletedFirstLesson = false,
    this.hasSeenExercisesTutorial = false,
    this.hasSeenJournalTutorial = false,
    this.hasLoggedWeightDuringTutorial = false,
    this.hasSeenWeightDiaryTutorial = false,
    this.hasVisitedWeightDiary = false,
    this.hasSeenPlantGrowthTutorial = false,
    this.hasSeenTimerClosingSlides = false,
    this.level = 1,
    this.exp = 0,
    this.lastSeedsGeneratedDate,
    this.lastGrowthWeek,
    this.lastGrowthYear,
    this.lastSeedsGeneratedAt,
    this.lastGrowthTasksGeneratedAt,
    this.streak = 0,
    this.lastStreakDate,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName;

  /// Helper method to safely convert Firestore values to DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      // Handle Firestore Timestamp objects (native Firebase timestamp type)
      if (value is Timestamp) {
        return value.toDate();
      }
      // Handle milliseconds since epoch as int
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      // Handle double (rare but possible)
      if (value is double) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      print('WARNING: Unexpected DateTime type: ${value.runtimeType}. Value: $value');
      return null;
    } catch (e) {
      print('ERROR parsing DateTime value: $e');
      return null;
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    try {
      // Parse createdAt - should be milliseconds since epoch or Firestore Timestamp
      DateTime parsedCreatedAt = _parseDateTime(data['createdAt']) ?? DateTime.now();

      // Parse lastLoginAt
      DateTime? parsedLastLoginAt = _parseDateTime(data['lastLoginAt']);

      // Parse other DateTime fields
      DateTime? parsedFcmTokenUpdatedAt = _parseDateTime(data['fcmTokenUpdatedAt']);
      DateTime? parsedLastSeedsGeneratedAt = _parseDateTime(data['lastSeedsGeneratedAt']);
      DateTime? parsedLastGrowthTasksGeneratedAt = _parseDateTime(data['lastGrowthTasksGeneratedAt']);
      DateTime? parsedLastStreakDate = _parseDateTime(data['lastStreakDate']);

      return UserModel(
        id: doc.id,
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        role: UserRole.values.firstWhere(
          (role) => role.name == data['role'],
          orElse: () => UserRole.patient,
        ),
        createdAt: parsedCreatedAt,
        lastLoginAt: parsedLastLoginAt,
        photoUrl: data['photoUrl'],
        fcmToken: data['fcmToken'],
        fcmTokenUpdatedAt: parsedFcmTokenUpdatedAt,
        preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
        onboardingCompleted: data['onboardingCompleted'] ?? false,
        onboardingPartiallyCompleted: data['onboardingPartiallyCompleted'] ?? false,
        hasSeenIntro: data['hasSeenIntro'] ?? false,
        hasSeenAppTutorial: data['hasSeenAppTutorial'] ?? false,
        hasCompletedFirstLesson: data['hasCompletedFirstLesson'] ?? false,
        hasSeenExercisesTutorial: data['hasSeenExercisesTutorial'] ?? false,
        hasSeenJournalTutorial: data['hasSeenJournalTutorial'] ?? false,
        hasLoggedWeightDuringTutorial: data['hasLoggedWeightDuringTutorial'] ?? false,
        hasSeenWeightDiaryTutorial: data['hasSeenWeightDiaryTutorial'] ?? false,
        hasSeenPlantGrowthTutorial: data['hasSeenPlantGrowthTutorial'] ?? false,
        hasSeenTimerClosingSlides: data['hasSeenTimerClosingSlides'] ?? false,
        level: data['level'] ?? 1,
        exp: data['exp'] ?? 0,
        lastSeedsGeneratedDate: data['lastSeedsGeneratedDate'],
        lastGrowthWeek: data['lastGrowthWeek'],
        lastGrowthYear: data['lastGrowthYear'],
        lastSeedsGeneratedAt: parsedLastSeedsGeneratedAt,
        lastGrowthTasksGeneratedAt: parsedLastGrowthTasksGeneratedAt,
        streak: data['streak'] ?? 0,
        lastStreakDate: parsedLastStreakDate,
      );
    } catch (e) {
      print('CRITICAL ERROR in UserModel.fromFirestore: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'fcmTokenUpdatedAt': fcmTokenUpdatedAt?.millisecondsSinceEpoch,
      'preferences': preferences,
      'onboardingCompleted': onboardingCompleted,
      'onboardingPartiallyCompleted': onboardingPartiallyCompleted,
      'hasSeenIntro': hasSeenIntro,
      'hasSeenAppTutorial': hasSeenAppTutorial,
      'hasCompletedFirstLesson': hasCompletedFirstLesson,
      'hasSeenExercisesTutorial': hasSeenExercisesTutorial,
      'hasSeenJournalTutorial': hasSeenJournalTutorial,
      'hasLoggedWeightDuringTutorial': hasLoggedWeightDuringTutorial,
      'hasSeenWeightDiaryTutorial': hasSeenWeightDiaryTutorial,
      'hasVisitedWeightDiary': hasVisitedWeightDiary,
      'hasSeenPlantGrowthTutorial': hasSeenPlantGrowthTutorial,
      'hasSeenTimerClosingSlides': hasSeenTimerClosingSlides,
      'level': level,
      'exp': exp,
      'lastSeedsGeneratedDate': lastSeedsGeneratedDate,
      'lastGrowthWeek': lastGrowthWeek,
      'lastGrowthYear': lastGrowthYear,
      'lastSeedsGeneratedAt': lastSeedsGeneratedAt?.millisecondsSinceEpoch,
      'lastGrowthTasksGeneratedAt': lastGrowthTasksGeneratedAt?.millisecondsSinceEpoch,
      'streak': streak,
      'lastStreakDate': lastStreakDate?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? photoUrl,
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
    bool? onboardingPartiallyCompleted,
    bool? hasSeenIntro,
    bool? hasSeenAppTutorial,
    bool? hasCompletedFirstLesson,
    bool? hasSeenExercisesTutorial,
    bool? hasSeenJournalTutorial,
    bool? hasLoggedWeightDuringTutorial,
    bool? hasSeenWeightDiaryTutorial,
    bool? hasVisitedWeightDiary,
    bool? hasSeenPlantGrowthTutorial,
    bool? hasSeenTimerClosingSlides,
    int? level,
    int? exp,
    String? lastSeedsGeneratedDate,
    int? lastGrowthWeek,
    int? lastGrowthYear,
    DateTime? lastSeedsGeneratedAt,
    DateTime? lastGrowthTasksGeneratedAt,
    int? streak,
    DateTime? lastStreakDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      fcmTokenUpdatedAt: fcmTokenUpdatedAt ?? this.fcmTokenUpdatedAt,
      preferences: preferences ?? this.preferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingPartiallyCompleted: onboardingPartiallyCompleted ?? this.onboardingPartiallyCompleted,
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
      hasSeenAppTutorial: hasSeenAppTutorial ?? this.hasSeenAppTutorial,
      hasCompletedFirstLesson: hasCompletedFirstLesson ?? this.hasCompletedFirstLesson,
      hasSeenExercisesTutorial: hasSeenExercisesTutorial ?? this.hasSeenExercisesTutorial,
      hasSeenJournalTutorial: hasSeenJournalTutorial ?? this.hasSeenJournalTutorial,
      hasLoggedWeightDuringTutorial: hasLoggedWeightDuringTutorial ?? this.hasLoggedWeightDuringTutorial,
      hasSeenWeightDiaryTutorial: hasSeenWeightDiaryTutorial ?? this.hasSeenWeightDiaryTutorial,
      hasVisitedWeightDiary: hasVisitedWeightDiary ?? this.hasVisitedWeightDiary,
      hasSeenPlantGrowthTutorial: hasSeenPlantGrowthTutorial ?? this.hasSeenPlantGrowthTutorial,
      hasSeenTimerClosingSlides: hasSeenTimerClosingSlides ?? this.hasSeenTimerClosingSlides,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      lastSeedsGeneratedDate: lastSeedsGeneratedDate ?? this.lastSeedsGeneratedDate,
      lastGrowthWeek: lastGrowthWeek ?? this.lastGrowthWeek,
      lastGrowthYear: lastGrowthYear ?? this.lastGrowthYear,
      lastSeedsGeneratedAt: lastSeedsGeneratedAt ?? this.lastSeedsGeneratedAt,
      lastGrowthTasksGeneratedAt: lastGrowthTasksGeneratedAt ?? this.lastGrowthTasksGeneratedAt,
      streak: streak ?? this.streak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.photoUrl == photoUrl &&
        other.onboardingCompleted == onboardingCompleted &&
        other.onboardingPartiallyCompleted == onboardingPartiallyCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      firstName,
      lastName,
      role,
      createdAt,
      lastLoginAt,
      photoUrl,
      onboardingCompleted,
      onboardingPartiallyCompleted,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }
}
