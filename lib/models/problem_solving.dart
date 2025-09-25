import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemSolving {
  final String id;
  final String userId;
  final String problemDescription; // Step 1: Identify problem
  final List<String> specificProblems; // Step 2: Specify problems accurately
  final List<PotentialSolution> potentialSolutions; // Step 3: Consider solutions + Step 4: Implications
  final List<String> chosenSolutionIds; // Step 5: Best solutions chosen
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProblemSolving({
    required this.id,
    required this.userId,
    required this.problemDescription,
    required this.specificProblems,
    required this.potentialSolutions,
    required this.chosenSolutionIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProblemSolving.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProblemSolving(
      id: doc.id,
      userId: data['userId'] ?? '',
      problemDescription: data['problemDescription'] ?? '',
      specificProblems: List<String>.from(data['specificProblems'] ?? []),
      potentialSolutions: (data['potentialSolutions'] as List<dynamic>? ?? [])
          .map((solutionData) => PotentialSolution.fromMap(solutionData as Map<String, dynamic>))
          .toList(),
      chosenSolutionIds: List<String>.from(data['chosenSolutionIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'problemDescription': problemDescription,
      'specificProblems': specificProblems,
      'potentialSolutions': potentialSolutions.map((solution) => solution.toMap()).toList(),
      'chosenSolutionIds': chosenSolutionIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  ProblemSolving copyWith({
    String? id,
    String? userId,
    String? problemDescription,
    List<String>? specificProblems,
    List<PotentialSolution>? potentialSolutions,
    List<String>? chosenSolutionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProblemSolving(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      problemDescription: problemDescription ?? this.problemDescription,
      specificProblems: specificProblems ?? this.specificProblems,
      potentialSolutions: potentialSolutions ?? this.potentialSolutions,
      chosenSolutionIds: chosenSolutionIds ?? this.chosenSolutionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProblemSolving(id: $id, problemDescription: $problemDescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProblemSolving && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  List<PotentialSolution> get chosenSolutions {
    return potentialSolutions.where((solution) => chosenSolutionIds.contains(solution.id)).toList();
  }

  bool get isComplete {
    return problemDescription.isNotEmpty &&
           specificProblems.isNotEmpty &&
           potentialSolutions.isNotEmpty &&
           chosenSolutionIds.isNotEmpty;
  }
}

class PotentialSolution {
  final String id;
  final String description;
  final String implications;

  const PotentialSolution({
    required this.id,
    required this.description,
    required this.implications,
  });

  factory PotentialSolution.fromMap(Map<String, dynamic> map) {
    return PotentialSolution(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      implications: map['implications'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'implications': implications,
    };
  }

  PotentialSolution copyWith({
    String? id,
    String? description,
    String? implications,
  }) {
    return PotentialSolution(
      id: id ?? this.id,
      description: description ?? this.description,
      implications: implications ?? this.implications,
    );
  }

  @override
  String toString() {
    return 'PotentialSolution(id: $id, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PotentialSolution && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool get isComplete {
    return description.isNotEmpty && implications.isNotEmpty;
  }
}
