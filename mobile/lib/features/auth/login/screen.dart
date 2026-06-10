import 'dart:ui';
import 'package:anxease/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:anxease/core/services/auth_service.dart';
import 'package:anxease/features/auth/register/screen.dart';
import 'package:anxease/features/home/shell.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/shared/widgets/link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscure = true;
  bool _loading = false;

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadLastEmail();
  }

  Future<void> _loadLastEmail() async {
    final email = await _authService.getLastEmail();
    if (email != null) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    glowController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userId = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (userId != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget glassInput({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    Widget? suffix,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: .25),
            border: Border.all(color: Colors.white.withValues(alpha: .3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: label.contains("Email")
                ? TextInputType.emailAddress
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _safeBack, // ✅ FIXED
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Sign in to continue",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),

                    const SizedBox(height: 50),

                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Colors.white.withValues(alpha: .15),
                      ),
                      child: Column(
                        children: [
                          glassInput(
                            controller: _emailController,
                            label: "Email Address",
                          ),

                          const SizedBox(height: 20),

                          glassInput(
                            controller: _passwordController,
                            label: "Password",
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscure = !_obscure;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 35),

                          AnimatedBuilder(
                            animation: glowController,
                            builder: (_, __) {
                              return SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  text: _loading ? "Signing In..." : "Sign In",
                                  onPressed: _loading ? () {} : _login,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text("Don't have an account?"),

                    const SizedBox(height: 8),

                    AppLink(
                      text: "Create an Account",
                      bold: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
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
