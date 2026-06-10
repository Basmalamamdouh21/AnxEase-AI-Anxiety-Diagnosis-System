import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/modern_button.dart';
import 'package:anxease/core/services/assessment_service.dart';
import 'package:anxease/core/services/profile_service.dart';
import 'package:anxease/core/models/user_profile.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/features/home/shell.dart';
import 'package:anxease/features/auth/logout/screen.dart';
import 'package:anxease/features/questions/steps/personal_info.dart';
import 'package:anxease/features/reports/analysis/screen.dart';
import 'package:anxease/core/theme/_colors.dart';
import './details.dart';

class ReportScreen extends StatefulWidget {
  final String userId;

  const ReportScreen({super.key, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? analysis;
  UserProfile? profile;

  bool loading = true;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final latest = await AssessmentService().getLatestAssessmentFromServer(
      widget.userId,
    );

    final user = await ProfileService().getProfile(widget.userId);

    if (!mounted) return;

    setState(() {
      analysis = latest?["analysis"];
      profile = user;
      loading = false;
    });
  }

  Future<void> _refresh() async {
    if (refreshing) return;

    setState(() {
      refreshing = true;
    });

    try {
      await AssessmentService().regenerateAnalysis(widget.userId);

      final latest = await AssessmentService().getLatestAssessmentFromServer(
        widget.userId,
      );

      final user = await ProfileService().getProfile(widget.userId);

      if (mounted) {
        setState(() {
          analysis = latest?["analysis"];
          profile = user;
        });
        await _load();
      }
    } catch (e) {
      debugPrint("Refresh error: $e");
    } finally {
      if (mounted) {
        setState(() {
          refreshing = false;
        });
        await _load();
      }
    }
  }

  Color severityColor() {
    switch (analysis?["severity"]) {
      case "Critical":
        return Colors.red;
      case "Severe":
        return Colors.orange;
      case "Moderate":
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _header(),
                      const SizedBox(height: 24),
                      _severityBanner(),
                      const SizedBox(height: 20),
                      _diagnosisCard(),
                      const SizedBox(height: 20),
                      _symptomsCard(),
                      const SizedBox(height: 20),
                      _therapyCard(),
                      const SizedBox(height: 16),
                      _medicationCard(),
                      const SizedBox(height: 20),
                      _adherenceCard(),
                      const SizedBox(height: 30),
                      _analysisButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.black,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            profile?.name ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        refreshing
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PersonalInfoScreen(userId: widget.userId),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell()),
              (route) => false,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LogoutConfirmScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _severityBanner() {
    final color = severityColor();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .18), color.withValues(alpha: .05)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .25),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .2),
            ),
            child: Icon(Icons.warning, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Severity Level: ${analysis?["severity"] ?? ""}",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: .95),
            Colors.white.withValues(alpha: .85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required List<Color> gradient,
  }) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: .4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _diagnosisCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.health_and_safety,
            title: "Clinical Diagnosis",
            gradient: const [Color(0xff36d1dc), Color(0xff5b86e5)],
          ),
          const SizedBox(height: 16),
          Text(
            analysis?["diagnosis"] ?? "",
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _symptomsCard() {
    final symptoms = (analysis?["symptoms"] ?? []) as List;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.psychology,
            title: "Detected Symptoms",
            gradient: const [Color(0xff667eea), Color(0xff764ba2)],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: symptoms.take(8).map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(s.toString(), style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _modernTreatmentCard({
    required String title,
    required IconData icon,
    required Map<String, dynamic> data,
    required List<Color> gradient,
  }) {
    final keys = data.keys.toList();

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: icon, title: title, gradient: gradient),
          const SizedBox(height: 18),
          ...keys
              .take(3)
              .map(
                (k) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_formatKey(k))),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 18),
          ModernButton(
            text: "View Full Plan",
            icon: icon,
            gradient: gradient,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TreatmentDetailsScreen(title: title, data: data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    String text = key.replaceAll('_', ' ');

    text = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    final words = text.split(' ');
    final formatted = words
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');

    return formatted;
  }

  Widget _therapyCard() {
    final therapy = Map<String, dynamic>.from(analysis?["therapy"] ?? {});

    return _modernTreatmentCard(
      title: "Therapy Plan",
      icon: Icons.psychology_alt,
      data: therapy,
      gradient: const [Color(0xff4facfe), Color(0xff00f2fe)],
    );
  }

  Widget _medicationCard() {
    final medication = Map<String, dynamic>.from(analysis?["medication"] ?? {});

    return _modernTreatmentCard(
      title: "Medication Plan",
      icon: Icons.medication,
      data: medication,
      gradient: const [Color(0xffff512f), Color(0xffdd2476)],
    );
  }

  Widget _adherenceCard() {
    final double adherence = (analysis?["adherence"] as num?)?.toDouble() ?? 0;
    final percent = (adherence * 100).toStringAsFixed(0);

    return _card(
      Column(
        children: [
          _sectionHeader(
            icon: Icons.monitor_heart,
            title: "Treatment Adherence",
            gradient: const [Color(0xff00c6ff), Color(0xff0072ff)],
          ),
          const SizedBox(height: 22),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: adherence,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$percent%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Adherence",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            adherence >= 0.8
                ? "Excellent treatment compliance"
                : adherence >= 0.5
                ? "Moderate treatment adherence"
                : "Low adherence — improvement recommended",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _analysisButton() {
    return ModernButton(
      text: "View Detailed AI Analysis",
      icon: Icons.analytics,
      gradient: const [Color(0xff667eea), Color(0xff764ba2)],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(userId: widget.userId),
          ),
        );
      },
    );
  }
}
