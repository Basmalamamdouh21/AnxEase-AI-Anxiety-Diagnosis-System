import 'package:flutter/material.dart';
import 'package:anxease/core/theme/_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, gradient }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? height;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.height,
    this.width,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  Color? _backgroundColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.primaryLight;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.gradient:
        return null;
    }
  }

  Color? _textColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        return AppColors.white;
      case AppButtonVariant.ghost:
        return AppColors.primary;
      case AppButtonVariant.gradient:
        return AppColors.primary;
    }
  }

  Gradient? _gradient() {
    if (widget.variant == AppButtonVariant.gradient) {
      return const LinearGradient(
        begin: Alignment(0.63, -0.78),
        end: Alignment(-0.63, 0.78),
        colors: [Color.fromARGB(255, 133, 184, 241), AppColors.gradientBottom],
        stops: [0.5183, 0.6645],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 56;
    final width = widget.width ?? double.infinity;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = widget.width ?? constraints.maxWidth;

        // Dynamic font scaling logic
        double fontSize;
        if (effectiveWidth < 140) {
          fontSize = 14;
        } else if (effectiveWidth < 200) {
          fontSize = 15;
        } else {
          fontSize = 17;
        }

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.96 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: _backgroundColor(),
                gradient: _gradient(),
                borderRadius: BorderRadius.circular(40),
                boxShadow: widget.variant == AppButtonVariant.gradient
                    ? [
                        if (!_pressed)
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                      ]
                    : widget.variant == AppButtonVariant.ghost
                    ? []
                    : [
                        if (!_pressed)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          color: _textColor(),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
