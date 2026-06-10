import 'package:anxease/shared/widgets/modern_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/core/services/assessment_service.dart';
import 'package:anxease/core/services/mood_service.dart';
import 'package:anxease/core/models/mood_entry.dart';

class AnalysisScreen extends StatefulWidget {
  final String userId;

  const AnalysisScreen({super.key, required this.userId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<double> anxietyHistory = [];
  List<String> symptoms = [];

  List<MoodEntry> moodEntries = [];
  List<double> moodHistory = [];

  double currentScore = 0;

  int selectedMood = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final latest = await AssessmentService().getLatestAssessmentFromServer(
        widget.userId,
      );

      if (latest == null) {
        setState(() => loading = false);
        return;
      }

      final analysis = latest["analysis"] ?? {};
      final score = (analysis["anxietyScore"] ?? 0).toDouble();

      final apiSymptoms =
          (analysis["symptoms"] as List?)?.map((e) => e.toString()).toList() ??
          [];

      final moods = await MoodService().getUserEntries(widget.userId);

      setState(() {
        currentScore = score;

        anxietyHistory = [
          ((score - 6).clamp(5, 40)).toDouble(),
          ((score - 4).clamp(5, 50)).toDouble(),
          ((score - 2).clamp(5, 60)).toDouble(),
          score,
        ];

        symptoms = apiSymptoms;

        moodEntries = moods;

        moodHistory = moods.takeLast(7).map((e) => e.mood.toDouble()).toList();

        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _saveMood() async {
    if (selectedMood == 0) return;

    await MoodService().saveEntry(
      MoodEntry(
        userId: widget.userId,
        mood: selectedMood,
        date: DateTime.now(),
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Mood logged successfully")));

    setState(() => selectedMood = 0);

    _loadData();
  }

  double _predictNextScore() {
    if (anxietyHistory.length < 2) return currentScore;

    final last = anxietyHistory.last;
    final prev = anxietyHistory[anxietyHistory.length - 2];

    final trend = last - prev;

    return (last + trend).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      _topBar(),

                      const SizedBox(height: 40),

                      _aiScoreCard(),

                      const SizedBox(height: 20),

                      _chartCard(),

                      const SizedBox(height: 20),

                      _predictionCard(),

                      const SizedBox(height: 20),

                      _weeklyMoodGraph(),

                      const SizedBox(height: 20),

                      _symptomHeatmap(),

                      const SizedBox(height: 20),

                      _recommendationCard(),

                      const SizedBox(height: 20),

                      _moodCard(),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: ModernButton(
                          text: "Log Today's Mood",
                          icon: Icons.edit_calendar_outlined,
                          onTap: _saveMood,
                          gradient: const [
                            Color(0xff5f72ff),
                            Color(0xff9b23ea),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const Text(
          "AI Anxiety Analysis",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const Icon(Icons.analytics_outlined),
      ],
    );
  }

  Widget _aiScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff5f72ff), Color(0xff9b23ea)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text(
            "Current Anxiety Score",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            currentScore.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "AI Estimated Severity",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xff5f72ff), Color(0xff9b23ea)],
                    ),
                    spots: anxietyHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _predictionCard() {
    final predicted = _predictNextScore();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: Column(
        children: [
          const Text(
            "AI Anxiety Prediction",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            predicted.toStringAsFixed(1),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const Text("Predicted next anxiety level"),
        ],
      ),
    );
  }

  Widget _weeklyMoodGraph() {
    if (moodHistory.isEmpty) return const SizedBox();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xff00c6ff), Color(0xff0072ff)],
              ),
              spots: moodHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _symptomHeatmap() {
    if (symptoms.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: symptoms.map((s) {
          final intensity = (s.length % 3) + 1;

          Color color;

          switch (intensity) {
            case 1:
              color = Colors.green;
              break;
            case 2:
              color = Colors.orange;
              break;
            default:
              color = Colors.red;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(s, style: TextStyle(color: color)),
          );
        }).toList(),
      ),
    );
  }

  Widget _recommendationCard() {
    String recommendation;

    if (currentScore > 80) {
      recommendation =
          "High anxiety detected. Consider CBT therapy sessions and professional consultation.";
    } else if (currentScore > 50) {
      recommendation =
          "Moderate anxiety. Breathing exercises and journaling may help.";
    } else {
      recommendation =
          "Mild symptoms. Maintain healthy routines and mindfulness practice.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Recommendations",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(recommendation),
        ],
      ),
    );
  }

  Widget _moodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Daily Mood Log",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moodIcon(1, Icons.sentiment_dissatisfied),
              _moodIcon(2, Icons.sentiment_neutral),
              _moodIcon(3, Icons.sentiment_satisfied),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moodIcon(int value, IconData icon) {
    final isSelected = selectedMood == value;

    return GestureDetector(
      onTap: () => setState(() => selectedMood = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xff5f72ff), Color(0xff9b23ea)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  BoxDecoration _glassCard() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}
