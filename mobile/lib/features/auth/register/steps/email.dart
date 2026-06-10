import 'package:flutter/material.dart';
import 'package:anxease/core/models/register.dart';
import 'package:anxease/shared/widgets/glass_input.dart';
import 'package:anxease/shared/widgets/button.dart';

class RegisterEmailStep extends StatefulWidget {
  final RegisterModel model;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RegisterEmailStep({
    super.key,
    required this.model,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterEmailStep> createState() => _RegisterEmailStepState();
}

class _RegisterEmailStepState extends State<RegisterEmailStep>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final email = TextEditingController();

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
    email.dispose();
    glowController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final input = value.trim();

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(input)) {
      return "Enter a valid email address";
    }

    return null;
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.model.email = email.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
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
              "Your Email",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "We'll use this to create your account",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 60),

            GlassInput(
              controller: email,
              label: "Email Address",
              hint: "example@email.com",
              type: TextInputType.emailAddress,
              validator: validateEmail,
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
                        color: Colors.blue.withValues(alpha: .25),
                        blurRadius: 16 + glowController.value * 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: AppButton(text: "Continue", onPressed: submit),
                );
              },
            ),
          ],
        ),
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
                width: c.maxWidth * .66,
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

        const Text("Step 2 of 3", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
