import 'package:anxease/core/models/register.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:flutter/material.dart';

class RegisterOtpStep extends StatefulWidget {
  final RegisterModel model;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const RegisterOtpStep({
    super.key,
    required this.model,
    required this.onBack,
    required this.onFinish,
  });

  @override
  State<RegisterOtpStep> createState() => _RegisterOtpStepState();
}

class _RegisterOtpStepState extends State<RegisterOtpStep> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          const Text("Verify OTP"),
          const SizedBox(height: 20),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
          ),
          const Spacer(),
          LinearProgressIndicator(value: 1),
          const SizedBox(height: 20),
          AppButton(
            text: "Verify",
            onPressed: () {
              widget.onFinish();
            },
          ),
        ],
      ),
    );
  }
}
