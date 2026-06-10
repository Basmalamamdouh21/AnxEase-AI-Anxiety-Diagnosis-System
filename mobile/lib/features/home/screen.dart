import 'dart:ui';
import 'package:anxease/features/questions/screen.dart';
import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/core/theme/_colors.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppGradientBackground(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -160,
              left: -120,
              child: Container(
                height: 340,
                width: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4D8FE3).withValues(alpha: .3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * .08),
              child: Column(
                children: [
                  SizedBox(height: size.height * .03),

                  const Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: size.height * .05),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .15),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: .12),
                              Colors.white.withValues(alpha: .04),
                            ],
                          ),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              "How are you feeling today?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Your mental wellbeing matters.\nLet's check in together.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionsScreen(userId: userId),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6FA6FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .45),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Start Diagnosis",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;

                        final robotHeight = h * 1.35;

                        final bubbleTop = -robotHeight * 0.68;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            /// glow under robot
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: 220,
                                height: h * 0.25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: .35),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// robot
                            Positioned(
                              bottom: h * 0.12,
                              left: -100 + (h * 0.09),
                              child: Image.asset(
                                "assets/images/home_robot.png",
                                height: robotHeight,
                                fit: BoxFit.contain,
                              ),
                            ),

                            /// speech bubble
                            Positioned(
                              top: bubbleTop,
                              left: robotHeight * 0.28,
                              child: Transform.rotate(
                                angle: -0.05,
                                child: Builder(
                                  builder: (context) {
                                    // dynamic bubble width (max 170)
                                    final bubbleWidth = (h * 0.6).clamp(
                                      0.0,
                                      170.0,
                                    );

                                    return SizedBox(
                                      width: bubbleWidth,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          /// bubble image
                                          Image.asset(
                                            "assets/images/text_box.png",
                                            width: bubbleWidth,
                                            fit: BoxFit.contain,
                                          ),

                                          /// bubble text
                                          Positioned(
                                            top: bubbleWidth * 0.25,
                                            child: Text(
                                              "Hi!",
                                              style: TextStyle(
                                                fontSize: bubbleWidth * 0.16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
