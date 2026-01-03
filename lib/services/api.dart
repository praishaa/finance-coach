import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000";

  // Helper to get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Login
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim().toLowerCase(),
        "password": password.trim(),
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)["token"];
      await AuthStorage.saveToken(token); // Save token
      return token;
    } else {
      throw Exception("Login failed");
    }
  }

  // Signup
  // Signup
  static Future<String> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name.trim(),
        "email": email.trim().toLowerCase(),
        "password": password.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)["token"];
      await AuthStorage.saveToken(token); // Save token

      // 🔥 ADD THIS - Save the name
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name.trim());

      return token;
    } else {
      throw Exception("Signup failed");
    }
  }

  // Add expense - WITH AUTH
  static Future<void> addExpense({
    required int amount,
    required String category,
    required DateTime date,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/expenses"),
      headers: await _getHeaders(),
      body: jsonEncode({
        "amount": amount,
        "category": category,
        "date": date.toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add expense");
    }
  }


  // Get expenses - WITH AUTH
  static Future<List<dynamic>> getExpenses() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/expenses"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch expenses");
    }
  }

  // Get summary - WITH AUTH
  static Future<Map<String, dynamic>> getSummary({
    int? month,
    int? year,
  }) async {
    final headers = await _getHeaders();

    final now = DateTime.now();
    final queryMonth = month ?? now.month;
    final queryYear = year ?? now.year;

    final response = await http.get(
      Uri.parse(
        "$baseUrl/expenses/summary?month=$queryMonth&year=$queryYear",
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch summary");
    }
  }


  // Monthly summary - WITH AUTH
  static Future<List<dynamic>> getMonthlySummary() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/expenses/monthly-summary"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch monthly summary");
    }
  }
  static Future<Map<String, dynamic>> getDaySummary({
    required DateTime date,
  }) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse(
        "$baseUrl/expenses/summary/day?date=${date.toIso8601String()}",
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch day summary");
    }
  }

  // Prediction - WITH AUTH
  static Future<int> getPrediction() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/expenses/predict-next-month"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["predicted"] as num).toInt();
    } else {
      throw Exception("Failed to fetch prediction");
    }
  }

  // AI advice
  static Future<String> getAdvice() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse("$baseUrl/advice"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["advice"];
    } else {
      throw Exception("Failed to fetch advice");
    }
  }

  // Investment advice
  static Future<String> getInvestmentAdvice(String riskLevel) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse("$baseUrl/advice/investment"),
      headers: headers,
      body: jsonEncode({"riskLevel": riskLevel}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["investmentAdvice"];
    } else {
      throw Exception("Failed to fetch investment advice");
    }
  }
  static Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // It reads the 'user_name' we saved during login
      String? name = prefs.getString('user_name');
      return name ?? "User"; // Fallback to "User" if nothing found
    } catch (e) {
      return "User";
    }
  }
}


