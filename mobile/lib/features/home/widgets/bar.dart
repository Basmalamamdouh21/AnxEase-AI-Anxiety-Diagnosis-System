import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:anxease/core/services/auth_service.dart';
import 'package:anxease/core/services/assessment_service.dart';
import 'package:anxease/features/questions/screen.dart';
import 'package:anxease/core/theme/_colors.dart';

class BottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  String? userId;
  bool loading = true;

  late AnimationController glowController;
  late Animation<double> glowAnimation;

  @override
  void initState() {
    super.initState();

    _init();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(
      begin: 0.85,
      end: 1.2,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final id = await AuthService().getCurrentUserId();

    if (!mounted) return;

    setState(() {
      userId = id;
      loading = false;
    });
  }

  /// ✅ FIXED: only decides if user can switch tabs
  Future<void> _handleTab(int index) async {
    if (userId == null) return;

    final hasAssessment = await AssessmentService().hasAssessment(userId!);

    if (!mounted) return;

    /// Redirect to onboarding if needed
    if (!hasAssessment) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuestionsScreen(userId: userId!)),
      );
      return;
    }

    /// ✅ ONLY switch tab (no push!)
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(height: 120);
    }

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// glass navigation bar
          Positioned(
            bottom: 18,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: .08),
                        Colors.white.withValues(alpha: .03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// chatbot icon
                      Expanded(
                        child: _navIcon(
                          icon: "assets/images/chatbot.png",
                          active: widget.currentIndex == 0,
                          onTap: () => _handleTab(0), // ✅ FIXED
                        ),
                      ),

                      const SizedBox(width: 90),

                      /// profile icon
                      Expanded(
                        child: _navIcon(
                          icon: "assets/images/profile.png",
                          active: widget.currentIndex == 2,
                          onTap: () => _handleTab(2), // ✅ FIXED
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// floating home button (this is a FLOW → navigation allowed)
          Positioned(
            bottom: 18,
            child: AnimatedBuilder(
              animation: glowController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -3 * glowAnimation.value),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  if (userId == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionsScreen(userId: userId!),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 86,
                  width: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF6FA6FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .6),
                        blurRadius: 35,
                        spreadRadius: 3,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/home.png",
                      width: 32,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon({
    required String icon,
    required VoidCallback onTap,
    required bool active,
  }) {
    final bool isChatbot = icon.contains("chatbot");

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          scale: active ? 1.2 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: active ? 1 : .7,
            child: Image.asset(
              icon,
              width: isChatbot ? (active ? 65 : 60) : (active ? 34 : 30),
              color: isChatbot ? null : Colors.white,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
