import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/core/services/auth_service.dart';
import 'package:anxease/features/welcome/screen.dart';

class LogoutConfirmScreen extends StatelessWidget {
  const LogoutConfirmScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/logout_robot.png", height: 180),

                    const SizedBox(height: 24),

                    const Text(
                      "Are you sure to logout\nof your account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 30),

                    AppButton(
                      text: "Log out",
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        _logout(context);
                      },
                    ),

                    const SizedBox(height: 14),

                    AppButton(
                      text: "Cancel",
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
