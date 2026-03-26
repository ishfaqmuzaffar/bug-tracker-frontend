import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

class BugTrackerApp extends StatefulWidget {
  const BugTrackerApp({super.key});

  @override
  State<BugTrackerApp> createState() => _BugTrackerAppState();
}

class _BugTrackerAppState extends State<BugTrackerApp> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      _loggedIn = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _loggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bug Tracking System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _loading
          ? const _SplashScreen()
          : (_loggedIn
                ? HomeShell(onLogout: _onLogout)
                : LoginScreen(onLoginSuccess: _onLoginSuccess)),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}