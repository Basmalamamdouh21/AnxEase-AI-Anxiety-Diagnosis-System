class AssessmentResult {
  final String userId;
  final Map<String, bool> medical;
  final Map<String, bool> anxiety;
  final Map<String, dynamic> mental;
  final DateTime createdAt;

  AssessmentResult({
    required this.userId,
    required this.medical,
    required this.anxiety,
    required this.mental,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "medical": medical,
    "anxiety": anxiety,
    "mental": mental,
    "createdAt": createdAt.toIso8601String(),
  };

  factory AssessmentResult.fromJson(Map<String, dynamic> json) =>
      AssessmentResult(
        userId: json["userId"],
        medical: Map<String, bool>.from(json["medical"]),
        anxiety: Map<String, bool>.from(json["anxiety"]),
        mental: Map<String, dynamic>.from(json["mental"]),
        createdAt: DateTime.parse(json["createdAt"]),
      );
}
