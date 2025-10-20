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
  final int level;
  final int exp;
  final String? lastSeedsGeneratedDate; // YYYY-MM-DD format
  final int? lastGrowthWeek;            // ISO week number
  final int? lastGrowthYear;            // Year for growth tasks
  final DateTime? lastSeedsGeneratedAt; // Full timestamp
  final DateTime? lastGrowthTasksGeneratedAt; // Full timestamp

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
    this.level = 1,
    this.exp = 0,
    this.lastSeedsGeneratedDate,
    this.lastGrowthWeek,
    this.lastGrowthYear,
    this.lastSeedsGeneratedAt,
    this.lastGrowthTasksGeneratedAt,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => UserRole.patient,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'])
          : null,
      photoUrl: data['photoUrl'],
      fcmToken: data['fcmToken'],
      fcmTokenUpdatedAt: data['fcmTokenUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['fcmTokenUpdatedAt'])
          : null,
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
      hasVisitedWeightDiary: data['hasVisitedWeightDiary'] ?? false,
      hasSeenPlantGrowthTutorial: data['hasSeenPlantGrowthTutorial'] ?? false,
      level: data['level'] ?? 1,
      exp: data['exp'] ?? 0,
      lastSeedsGeneratedDate: data['lastSeedsGeneratedDate'],
      lastGrowthWeek: data['lastGrowthWeek'],
      lastGrowthYear: data['lastGrowthYear'],
      lastSeedsGeneratedAt: data['lastSeedsGeneratedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastSeedsGeneratedAt'])
          : null,
      lastGrowthTasksGeneratedAt: data['lastGrowthTasksGeneratedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastGrowthTasksGeneratedAt'])
          : null,
    );
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
      'level': level,
      'exp': exp,
      'lastSeedsGeneratedDate': lastSeedsGeneratedDate,
      'lastGrowthWeek': lastGrowthWeek,
      'lastGrowthYear': lastGrowthYear,
      'lastSeedsGeneratedAt': lastSeedsGeneratedAt?.millisecondsSinceEpoch,
      'lastGrowthTasksGeneratedAt': lastGrowthTasksGeneratedAt?.millisecondsSinceEpoch,
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
    int? level,
    int? exp,
    String? lastSeedsGeneratedDate,
    int? lastGrowthWeek,
    int? lastGrowthYear,
    DateTime? lastSeedsGeneratedAt,
    DateTime? lastGrowthTasksGeneratedAt,
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
      level: level ?? this.level,
      exp: exp ?? this.exp,
      lastSeedsGeneratedDate: lastSeedsGeneratedDate ?? this.lastSeedsGeneratedDate,
      lastGrowthWeek: lastGrowthWeek ?? this.lastGrowthWeek,
      lastGrowthYear: lastGrowthYear ?? this.lastGrowthYear,
      lastSeedsGeneratedAt: lastSeedsGeneratedAt ?? this.lastSeedsGeneratedAt,
      lastGrowthTasksGeneratedAt: lastGrowthTasksGeneratedAt ?? this.lastGrowthTasksGeneratedAt,
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
