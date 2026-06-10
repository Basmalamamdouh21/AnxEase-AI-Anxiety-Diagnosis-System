import 'dart:ui';
import 'package:flutter/material.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? type;
  final Widget? suffix;

  final String? Function(String?)? validator;

  const GlassInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.type,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: .25),
            border: Border.all(color: Colors.white.withValues(alpha: .3)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            validator: validator,

            style: const TextStyle(color: Colors.black),

            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              suffixIcon: suffix,

              border: InputBorder.none,

              errorStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),

              errorMaxLines: 2,
            ),
          ),
        ),
      ),
    );
  }
}
