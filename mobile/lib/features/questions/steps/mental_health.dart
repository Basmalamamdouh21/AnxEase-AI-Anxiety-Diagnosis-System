import 'package:anxease/core/models/question_flow.dart';
import 'package:anxease/core/services/question_flow_service.dart';
import 'package:anxease/core/utils/assessment_mapper.dart';
import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/core/services/assessment_service.dart';
import '../../reports/screen.dart';
import '../_baseLayout.dart';
import '../widgets/toggle.dart';
import '../widgets/progress_bar.dart';

class MentalHealthScreen extends StatefulWidget {
  final QuestionsFlow flow;

  const MentalHealthScreen({super.key, required this.flow});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  int step = 1;
  bool submitting = false;

  Map<String, dynamic> get answers => widget.flow.mental;

  final Map<String, TextEditingController> textControllers = {};

  @override
  void initState() {
    super.initState();
    _restoreControllers();
  }

  @override
  void dispose() {
    for (final c in textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _restoreControllers() {
    for (final entry in answers.entries) {
      if (entry.value is String) {
        textControllers[entry.key] = TextEditingController(text: entry.value);
      }
    }
  }

  Future<void> _saveFlow() async {
    await QuestionsFlowService().saveFlow(widget.flow);
  }


  Future<void> submitAssessment() async {
    if (submitting) return;

    setState(() => submitting = true);

    try {
      await _saveFlow();

      final result = AssessmentMapper.fromFlow(widget.flow);

      await AssessmentService().analyze(result);

      await QuestionsFlowService().clear(widget.flow.userId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(userId: widget.flow.userId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Submission failed: $e")));
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  final step1 = [
    {
      "section": "1. Mood",
      "questions": [
        {
          "text": "How have you been feeling emotionally lately?",
          "type": "text",
        },
        {"text": "Do you feel sad, empty, or hopeless?", "type": "yesno"},
        {
          "text": "Have you lost interest in activities you used to enjoy?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "2. Anxiety",
      "questions": [
        {"text": "Do you feel constantly tense or anxious?", "type": "yesno"},
        {"text": "Do you experience sudden panic attacks?", "type": "yesno"},
        {
          "text": "Does anxiety interfere with your daily activities?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "3. Sleep",
      "questions": [
        {"text": "How is your sleep?", "type": "text"},
        {
          "text": "Do you have trouble falling asleep or staying asleep?",
          "type": "yesno",
        },
        {"text": "Do you sleep more than usual?", "type": "yesno"},
      ],
    },
  ];

  final step2 = [
    {
      "section": "4. Energy & Concentration",
      "questions": [
        {"text": "How is your energy level?", "type": "text"},
        {"text": "Do you feel tired most of the day?", "type": "yesno"},
        {"text": "Do you have difficulty concentrating?", "type": "yesno"},
      ],
    },
    {
      "section": "5. Appetite & Weight",
      "questions": [
        {
          "text": "Have you noticed any changes in your appetite?",
          "type": "yesno",
        },
        {
          "text": "Have you gained or lost weight unintentionally?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "6. Negative Thoughts",
      "questions": [
        {
          "text":
              "Do you have thoughts of being worthless or a burden on others?",
          "type": "yesno",
        },
        {"text": "Do you dwell on past mistakes?", "type": "yesno"},
      ],
    },
  ];

  final step3 = [
    {
      "section": "7. Social Behavior",
      "questions": [
        {
          "text": "Are you avoiding people or social situations?",
          "type": "yesno",
        },
        {
          "text": "Do you prefer to stay alone most of the time?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "8. Psychotic Symptoms (For clinical use only)",
      "questions": [
        {"text": "Do you hear voices that others cannot hear?", "type": "text"},
        {
          "text": "Do you believe someone is watching or trying to harm you?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "9. Daily Functioning",
      "questions": [
        {
          "text":
              "Are your symptoms affecting your work, studies, or relationships?",
          "type": "yesno",
        },
        {
          "text": "Do you find it difficult to complete daily tasks?",
          "type": "yesno",
        },
      ],
    },
    {
      "section": "10. Safety",
      "questions": [
        {"text": "Have you had thoughts of harming yourself?", "type": "yesno"},
        {"text": "Have you felt that you might harm others?", "type": "yesno"},
      ],
    },
  ];

  List<Map<String, dynamic>> get currentData {
    if (step == 1) return step1;
    if (step == 2) return step2;
    return step3;
  }

  void next() {
    if (step < 3) {
      setState(() => step++);
    } else {
      submitAssessment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BaseLayout(
          title: "General Mental Health Assessment",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...currentData.map((section) => _buildSection(section)),
              const SizedBox(height: 20),
              StepProgressBar(current: step, total: 3),
              const SizedBox(height: 20),
              AppButton(
                text: step == 3 ? "Submit" : "Next",
                onPressed: submitting ? () {} : next,
              ),
            ],
          ),
        ),

        if (submitting)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section["section"],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...section["questions"].map<Widget>((q) {
            final text = q["text"];
            final type = q["type"];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  type == "yesno"
                      ? YesNoToggle(
                          value: answers[text],
                          onChanged: (val) async {
                            answers[text] = val;
                            await _saveFlow();
                            setState(() {});
                          },
                        )
                      : _textField(text),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _textField(String key) {
    textControllers.putIfAbsent(
      key,
      () => TextEditingController(text: answers[key] ?? ""),
    );

    return SizedBox(
      width: 150,
      child: TextField(
        controller: textControllers[key],
        onChanged: (val) async {
          answers[key] = val;
          await _saveFlow();
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
