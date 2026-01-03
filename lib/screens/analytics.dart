import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> categoryColors = [
      Colors.teal,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.cyan,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending Breakdown"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getSummary(), // month summary
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final int totalSpent =
          (snapshot.data!["totalSpent"] as num).toInt();

          final Map<String, dynamic> categoryTotals =
              snapshot.data!["categoryTotals"] ?? {};

          if (categoryTotals.isEmpty) {
            return const Center(child: Text("No category data"));
          }

          final dataEntries = categoryTotals.entries.toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// 🍩 DONUT CHART
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 240,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 70,
                          sectionsSpace: 3,
                          sections: dataEntries.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value =
                            (entry.value.value as num).toDouble();

                            return PieChartSectionData(
                              value: value,
                              title: "",
                              radius: 20,
                              color: categoryColors[
                              index % categoryColors.length],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total",
                          style:
                          TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          "₹$totalSpent",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// 📋 CATEGORY LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: dataEntries.length,
                    itemBuilder: (context, index) {
                      final entry = dataEntries[index];
                      final category = entry.key;
                      final value =
                      (entry.value as num).toDouble();
                      final percentage =
                      (value / totalSpent * 100).toStringAsFixed(1);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: categoryColors[
                              index % categoryColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            category,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${value.toInt()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "$percentage%",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


