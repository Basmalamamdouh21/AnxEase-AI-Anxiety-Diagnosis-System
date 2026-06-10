import 'package:flutter/material.dart';
import '../_baseLayout.dart';
import '../widgets/toggle.dart';
import '../widgets/progress_bar.dart';
import 'anxiety.dart';
import 'package:anxease/core/models/question_flow.dart';
import 'package:anxease/core/services/question_flow_service.dart';
import 'package:anxease/shared/widgets/button.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String userId;
  const MedicalHistoryScreen({super.key, required this.userId});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  int step = 1;
  late QuestionsFlow flow;

  final questions = [
    "Do you have high blood pressure?",
    "Do you have diabetes?",
    "Do you have any heart problems?",
    "Do you have thyroid issues?",
    "Do you have asthma or chest allergies?",
    "Do you have stomach or colon problems?",
    "Do you have any liver disease?",
    "Do you have kidney problems?",
    "Do you have migraines or nerve problems?",
    "Do you have anxiety or depression?",
    "Do you have anemia?",
    "Do you have any autoimmune diseases?",
    "Do you have joint or bone problems?",
    "Do you have skin allergies?",
    "(For females) Is your period regular?",
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    flow = await QuestionsFlowService().loadOrCreate(widget.userId);
    setState(() {});
  }

  List<String> get currentQuestions {
    if (step == 1) return questions.sublist(0, 8);
    if (step == 2) return questions.sublist(8, 15);
    return questions.sublist(15);
  }

  void _update(String q, bool val) async {
    flow.medical[q] = val;
    await QuestionsFlowService().saveFlow(flow);
    setState(() {});
  }

  void next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnxietyScreen(flow: flow)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Medical History Questionnaire",

      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepProgressBar(current: step, total: 2),
          const SizedBox(height: 16),
          AppButton(text: step == 2 ? "Submit" : "Next", onPressed: next),
        ],
      ),

      child: Column(
        children: [
          ...currentQuestions.map(
            (q) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      q,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  YesNoToggle(
                    value: flow.medical[q],
                    onChanged: (v) => _update(q, v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
