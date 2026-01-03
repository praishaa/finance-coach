import 'package:flutter/material.dart';
import 'home.dart';
import 'analytics.dart';
import 'monthly_trend.dart';
import 'prediction.dart';
import 'advice.dart';
import '../utils/auth_storage.dart';
import 'login.dart'; // ✅ ADD THIS IMPORT

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AnalyticsScreen(),
    const MonthlyTrendScreen(),
    const PredictionScreen(),
    const AdviceScreen(),
    const SizedBox(), // logout tab placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 5) {
            await AuthStorage.logout();
            // ✅ ADD NAVIGATION AFTER LOGOUT
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            }
            return;
          }

          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Trends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: "Predict",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Advice",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }
}