class QuestionsFlow {
  final String userId;

  Map<String, dynamic> medical = {};
  Map<String, dynamic> anxiety = {};
  Map<String, dynamic> mental = {};

  QuestionsFlow({required this.userId});

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "medical": medical,
    "anxiety": anxiety,
    "mental": mental,
  };

  factory QuestionsFlow.fromJson(Map<String, dynamic> json) {
    return QuestionsFlow(userId: json["userId"])
      ..medical = Map<String, dynamic>.from(json["medical"] ?? {})
      ..anxiety = Map<String, dynamic>.from(json["anxiety"] ?? {})
      ..mental = Map<String, dynamic>.from(json["mental"] ?? {});
  }
}
