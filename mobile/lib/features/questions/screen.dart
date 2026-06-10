import 'package:flutter/material.dart';
import 'package:anxease/core/services/profile_service.dart';
import 'steps/personal_info.dart';
import 'steps/medical_history.dart';

class QuestionsScreen extends StatefulWidget {
  final String userId;
  const QuestionsScreen({super.key, required this.userId});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await ProfileService().getProfile(widget.userId);

    if (!mounted) return;

    if (profile == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalInfoScreen(userId: widget.userId),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalHistoryScreen(userId: widget.userId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
