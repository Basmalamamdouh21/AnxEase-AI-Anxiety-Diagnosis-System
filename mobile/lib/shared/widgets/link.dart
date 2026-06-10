import 'package:flutter/material.dart';
import 'package:anxease/core/theme/_colors.dart';

class AppLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool bold;

  const AppLink({
    super.key,
    required this.text,
    required this.onTap,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
