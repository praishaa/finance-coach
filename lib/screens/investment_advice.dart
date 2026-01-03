import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/app_theme.dart';

class InvestmentAdviceScreen extends StatefulWidget {
  const InvestmentAdviceScreen({super.key});

  @override
  State<InvestmentAdviceScreen> createState() => _InvestmentAdviceScreenState();
}

class _InvestmentAdviceScreenState extends State<InvestmentAdviceScreen> {
  String riskLevel = "Medium";
  String? advice;
  bool loading = false;

  void fetchAdvice() async {
    setState(() {
      loading = true;
      advice = null;
    });

    try {
      final result = await ApiService.getInvestmentAdvice(riskLevel);
      setState(() => advice = result);
    } catch (e) {
      setState(() => advice = "Failed to load advice. Check connection.");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Investment Advisor"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskSelector(),
            const SizedBox(height: 32),
            _buildActionSection(),
            const SizedBox(height: 32),
            _buildResultArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Risk Tolerance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["Low", "Medium", "High"].map((level) {
            bool isSelected = riskLevel == level;
            return ChoiceChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (val) => setState(() => riskLevel = level),
              selectedColor: _getRiskColor(level).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? _getRiskColor(level) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: isSelected ? _getRiskColor(level) : Colors.white10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRiskColor(String level) {
    if (level == "Low") return Colors.greenAccent;
    if (level == "Medium") return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Widget _buildActionSection() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Icon(Icons.psychology_alt),
        onPressed: loading ? null : fetchAdvice,
        label: const Text("Generate Personalized Advice"),
      ),
    );
  }

  Widget _buildResultArea() {
    if (loading) return const Center(child: Text("Consulting AI Market Models..."));

    if (advice == null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text("Select a risk level to see insights", style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getRiskColor(riskLevel).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: _getRiskColor(riskLevel), size: 20),
              const SizedBox(width: 8),
              Text("$riskLevel Risk Strategy", style: TextStyle(color: _getRiskColor(riskLevel), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(advice!, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}
