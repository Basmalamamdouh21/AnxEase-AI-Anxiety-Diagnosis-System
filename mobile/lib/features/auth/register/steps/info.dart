import 'package:flutter/material.dart';
import 'package:anxease/core/models/register.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/shared/widgets/glass_input.dart';

class RegisterInfoStep extends StatefulWidget {
  final RegisterModel model;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RegisterInfoStep({
    super.key,
    required this.model,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterInfoStep> createState() => _RegisterInfoStepState();
}

class _RegisterInfoStepState extends State<RegisterInfoStep>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final birthday = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthday.text = picked.toIso8601String().split("T").first;
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.model.name = name.text.trim();
    widget.model.birthday = birthday.text;
    widget.model.address = address.text.trim();
    widget.model.phone = phone.text.trim();

    widget.onNext();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  }

  String? validateBirthday(String? value) {
    if (value == null || value.isEmpty) {
      return "Birthday is required";
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Address is required";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone is required";
    }

    final input = value.trim();

    // Egyptian phone formats:
    // 01XXXXXXXXX (11 digits)
    // +201XXXXXXXXX (international)
    final egyptPhoneRegex = RegExp(r'^(?:\+20|0)?1[0125]\d{8}$');

    if (!egyptPhoneRegex.hasMatch(input)) {
      return "Enter a valid Egyptian phone number";
    }

    return null;
  }

  @override
  void dispose() {
    name.dispose();
    birthday.dispose();
    address.dispose();
    phone.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .3,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tell us about yourself",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: glowController,
                builder: (_, __) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withValues(alpha: .15),
                    ),
                    child: Column(
                      children: [
                        GlassInput(
                          controller: name,
                          label: "Name",
                          hint: "Your full name",
                          validator: validateName,
                        ),

                        const SizedBox(height: 18),

                        GestureDetector(
                          onTap: pickBirthday,
                          child: AbsorbPointer(
                            child: GlassInput(
                              controller: birthday,
                              label: "Birthday",
                              hint: "Select birthday",
                              validator: validateBirthday,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        GlassInput(
                          controller: address,
                          label: "Address",
                          hint: "City or location",
                          validator: validateAddress,
                        ),

                        const SizedBox(height: 18),

                        GlassInput(
                          controller: phone,
                          label: "Phone",
                          hint: "+20",
                          type: TextInputType.phone,
                          validator: validatePhone,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              _progress(),

              const SizedBox(height: 25),

              AnimatedBuilder(
                animation: glowController,
                builder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppButton(text: "Continue", onPressed: submit),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
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
                width: c.maxWidth * .33,
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

        const Text("Step 1 of 3", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
