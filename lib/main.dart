import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'screens/login.dart';
import 'utils/auth_storage.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Coach AI',
      theme: AppTheme.darkTheme.copyWith(
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: AuthStorage.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // LOGGED IN
          if (snapshot.hasData && snapshot.data != null) {
            return const MainShell();
          }

          // NOT LOGGED IN
          return const LoginScreen();
        },
      ),
    );
  }
}

// Splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.auto_graph_rounded,
              size: 80,
              color: AppColors.primaryEmerald,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppColors.primaryEmerald,
            ),
          ],
        ),
      ),
    );
  }
}
