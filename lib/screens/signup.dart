import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/auth_storage.dart';
import 'login.dart';
import 'main_shell.dart'; // ✅ ADD THIS IMPORT

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> signup() async {
    setState(() => loading = true);

    try {
      await ApiService.signup(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      // ✅ NAVIGATE AFTER SUCCESS
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
      return;

    } catch (e) {
      final token = await AuthStorage.getToken();

      if (token != null) {
        // ✅ NAVIGATE IF TOKEN EXISTS
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: signup,
              child: const Text("Create Account"),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}