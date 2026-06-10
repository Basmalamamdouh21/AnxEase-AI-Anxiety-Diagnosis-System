import 'package:flutter/material.dart';
import 'package:anxease/core/theme/_colors.dart';
import 'package:anxease/core/theme/_text_styles.dart';
import 'package:anxease/features/auth/login/screen.dart';
import 'package:anxease/features/auth/register/screen.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/shared/widgets/link.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),

                Text(
                  "Welcome to AnxEase!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.splashTitle(
                    context,
                  ).copyWith(color: AppColors.primaryText),
                ),

                const Spacer(),

                Image.asset(
                  'assets/images/welcome_robot.png',
                  width: size.width * 0.6,
                ),

                const Spacer(),

                AppButton(
                  text: "Sign up",
                  width: size.width * 0.5,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.025),
                AppButton(
                  text: "Sign in",
                  width: size.width * 0.5,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.04),

                AppLink(text: "Terms and conditions", onTap: () {}),

                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
