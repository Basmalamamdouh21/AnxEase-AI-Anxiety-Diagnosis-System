import '../models/question_flow.dart';
import '../models/assessment_result.dart';

class AssessmentMapper {
  static AssessmentResult fromFlow(QuestionsFlow flow) {
    return AssessmentResult(
      userId: flow.userId,
      medical: Map<String, bool>.from(flow.medical),
      anxiety: Map<String, bool>.from(flow.anxiety),
      mental: Map<String, dynamic>.from(flow.mental),
      createdAt: DateTime.now(),
    );
  }
}
