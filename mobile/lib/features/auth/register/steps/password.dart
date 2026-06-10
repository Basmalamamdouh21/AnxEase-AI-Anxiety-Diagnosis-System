import 'package:flutter/material.dart';
import 'package:anxease/core/models/register.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/shared/widgets/glass_input.dart';

class RegisterPasswordStep extends StatefulWidget {
  final RegisterModel model;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const RegisterPasswordStep({
    super.key,
    required this.model,
    required this.onFinish,
    required this.onBack,
  });

  @override
  State<RegisterPasswordStep> createState() => _RegisterPasswordStepState();
}

class _RegisterPasswordStepState extends State<RegisterPasswordStep>
    with SingleTickerProviderStateMixin {
  final password = TextEditingController();
  final confirm = TextEditingController();

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    glowController.dispose();
    super.dispose();
  }

  void submit() {
    if (password.text.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password too short")));
      return;
    }

    if (password.text != confirm.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    widget.model.password = password.text;

    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Create Password",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: .4,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Choose a secure password",
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 60),

          GlassInput(
            controller: password,
            label: "Password",
            hint: "••••••••",
            obscure: true,
          ),

          const SizedBox(height: 20),

          GlassInput(
            controller: confirm,
            label: "Confirm Password",
            hint: "••••••••",
            obscure: true,
          ),

          const Spacer(),

          _progress(),

          const SizedBox(height: 30),

          AnimatedBuilder(
            animation: glowController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: .3),
                      blurRadius: 18 + glowController.value * 18,
                    ),
                  ],
                ),
                child: AppButton(text: "Create Account", onPressed: submit),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.withValues(alpha: .2),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              return Container(
                width: c.maxWidth,
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
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        const Text("Step 3 of 3", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
