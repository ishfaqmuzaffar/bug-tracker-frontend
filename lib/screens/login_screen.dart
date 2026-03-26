import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  void login() async {
    setState(() => loading = true);

    try {
      await ApiService.login(email.text, password.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 10,
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Bug Tracker Login", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading ? const CircularProgressIndicator() : const Text("Login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}