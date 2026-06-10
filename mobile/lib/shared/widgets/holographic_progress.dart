import 'package:flutter/material.dart';

class HolographicProgress extends StatelessWidget {
  final double progress;
  final String label;

  const HolographicProgress({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.withValues(alpha: .2),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xff00E5FF),
                    Color(0xff2979FF),
                    Color(0xff651FFF),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
