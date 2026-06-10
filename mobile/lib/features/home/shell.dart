import 'package:flutter/material.dart';
import 'screen.dart';
import 'widgets/bar.dart';
import 'package:anxease/core/services/auth_service.dart';
import 'package:anxease/features/chatbot/screen.dart';
import 'package:anxease/features/reports/screen.dart';

class HomeShell extends StatefulWidget {
  final bool forceHome;

  const HomeShell({super.key, this.forceHome = true});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 1;
  String? userId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.forceHome) {
      currentIndex = 1;
    }
  }

  Future<void> _init() async {
    final id = await AuthService().getCurrentUserId();

    if (!mounted) return;

    setState(() {
      userId = id;
      loading = false;
    });
  }

  void changeTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (loading || userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      ChatbotScreen(userId: userId!),
      HomeScreen(userId: userId!),
      ReportScreen(userId: userId!),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: (currentIndex == 0 || currentIndex == 2)
          ? null
          : BottomBar(currentIndex: currentIndex, onTap: changeTab),
    );
  }
}
