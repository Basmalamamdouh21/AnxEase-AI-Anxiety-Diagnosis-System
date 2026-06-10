import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/core/services/auth_service.dart';
import 'package:anxease/core/services/profile_service.dart';
import 'package:anxease/core/models/register.dart';
import 'package:anxease/core/models/user_profile.dart';
import 'package:anxease/features/home/shell.dart';

import 'steps/info.dart';
import 'steps/email.dart';
import 'steps/password.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _controller = PageController();
  final RegisterModel model = RegisterModel();

  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  int currentStep = 0;
  bool loading = false;

  void next() {
    if (currentStep < 2) {
      setState(() => currentStep++);

      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previous() {
    if (currentStep > 0) {
      setState(() => currentStep--);

      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _safeBack();
    }
  }

  void _safeBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    }
  }

  Future<void> _register() async {
    setState(() => loading = true);

    try {
      final userId = await _authService.register(
        model.email!.trim(),
        model.password!.trim(),
      );

      if (userId == null) {
        throw Exception("Registration failed");
      }

      final profile = UserProfile(
        userId: userId,
        name: model.name ?? "",
        date: DateTime.parse(model.birthday ?? "2000-01-01"),
        username: model.name ?? "",
        phone: model.phone ?? "",
        country: "",
        city: model.address ?? "",
        job: "",
        weight: 0,
        height: 0,
        gender: "",
        maritalStatus: "",
        hasInsurance: false,
      );

      await _profileService.saveProfile(profile);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RegisterInfoStep(
                    model: model,
                    onNext: next,
                    onBack: previous,
                  ),
                  RegisterEmailStep(
                    model: model,
                    onNext: next,
                    onBack: previous,
                  ),
                  RegisterPasswordStep(
                    model: model,
                    onBack: previous,
                    onFinish: _register,
                  ),
                ],
              ),

              if (loading)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
