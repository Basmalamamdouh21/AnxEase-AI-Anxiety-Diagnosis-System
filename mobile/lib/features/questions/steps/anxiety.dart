import 'package:anxease/features/questions/_baseLayout.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'mental_health.dart';
import '../widgets/toggle.dart';
import '../widgets/progress_bar.dart';
import 'package:anxease/core/models/question_flow.dart';
import 'package:anxease/core/services/question_flow_service.dart';

class AnxietyScreen extends StatefulWidget {
  final QuestionsFlow flow;
  const AnxietyScreen({super.key, required this.flow});

  @override
  State<AnxietyScreen> createState() => _AnxietyScreenState();
}

class _AnxietyScreenState extends State<AnxietyScreen> {
  int step = 1;

  final List<String> questions = [
    "Did any specific event happen before the anxiety started?",
    "Are you currently under stress?",
    "Is there a family history of anxiety?",
    "Have you ever experienced trauma?",
    "Have your sleep habits changed recently?",
    "Have your eating habits changed recently?",
    "Do you consume caffeine regularly?",
    "Do you take any medications?",
    "Do you feel supported by friends or family?",
    "Do you avoid certain places because of anxiety?",
    "Did you face strict parenting in childhood?",
    "Do you often feel anxious without a clear reason?",
    "Do you experience sudden panic attacks?",
    "Do you avoid social situations due to fear?",
    "Do you have intrusive thoughts?",
    "Do you perform repetitive behaviors?",
    "Have you experienced a traumatic event affecting sleep?",
    "Do your symptoms occur frequently?",
    "Do symptoms last a long time?",
    "Do symptoms interfere with daily life?",
    "Do you have coping methods?",
    "Have you been diagnosed before?",
    "Have you taken psychiatric medication before?",
  ];

  List<String> get currentQuestions {
    if (step == 1) return questions.sublist(0, 8);
    if (step == 2) return questions.sublist(8, 16);
    return questions.sublist(16);
  }

  void _update(String q, bool val) async {
    widget.flow.anxiety[q] = val;
    await QuestionsFlowService().saveFlow(widget.flow);
    setState(() {});
  }

  void next() {
    if (step < 3) {
      setState(() => step++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentalHealthScreen(flow: widget.flow),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Anxiety Assessment Questions",

      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepProgressBar(current: step, total: 3),
          const SizedBox(height: 16),
          AppButton(text: step == 3 ? "Submit" : "Next", onPressed: next),
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
                    value: widget.flow.anxiety[q],
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
