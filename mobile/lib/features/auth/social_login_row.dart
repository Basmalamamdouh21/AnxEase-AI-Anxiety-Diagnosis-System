import 'package:flutter/material.dart';

class SocialLoginRow extends StatelessWidget {
  final VoidCallback? onApple;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;

  const SocialLoginRow({
    super.key,
    this.onApple,
    this.onGoogle,
    this.onFacebook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SocialIcon(
          imagePath: 'assets/images/social/apple.png',
          onTap: onApple,
        ),
        _SocialIcon(
          imagePath: 'assets/images/social/google.png',
          onTap: onGoogle,
        ),
        _SocialIcon(
          imagePath: 'assets/images/social/facebook.png',
          onTap: onFacebook,
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const _SocialIcon({required this.imagePath, this.onTap});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.92 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              if (!_pressed)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(widget.imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
