import 'package:flutter/material.dart';

class GlowButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GlowButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xff00E5FF), Color(0xff2979FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2979FF).withValues(alpha: .6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
