import 'package:flutter/material.dart';
import '../utils/auth_storage.dart';
import 'login.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔐 NOT LOGGED IN
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // ✅ LOGGED IN
        return const MainShell();
      },
    );
  }
}
