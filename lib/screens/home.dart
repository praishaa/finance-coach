import 'package:flutter/material.dart';
import '../services/api.dart';
import 'add_expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> summaryFuture;
  String userName = "";
  final ScrollController _monthScrollController = ScrollController();

  DateTime selectedDate = DateTime.now();
  bool isDaySelected = false;
  bool showCalendar = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadUserName();
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  void _loadUserName() async {
    final name = await ApiService.getUserName();
    if (mounted) {
      setState(() {
        userName = name;
      });
    }
  }

  void _loadSummary() {
    setState(() {
      if (isDaySelected) {
        summaryFuture = ApiService.getDaySummary(date: selectedDate);
      } else {
        summaryFuture = ApiService.getSummary(
          month: selectedDate.month,
          year: selectedDate.year,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isDaySelected
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(selectedDate: selectedDate),
            ),
          );
          _loadSummary();
        },
        child: const Icon(Icons.add),
      )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<Map<String, dynamic>>(
              future: summaryFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final totalSpent = (snapshot.data!["totalSpent"] as num).toInt();
                final Map<String, dynamic> categoryTotals =
                    snapshot.data!["categoryTotals"] ?? {};

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🎨 HEADER
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              "GENSAVE AI",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                fontFamily: 'Orbitron',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userName.isEmpty ? "Hi! 👋" : "Hi, $userName! 👋",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 🔷 TOTAL SPENT
                    Card(
                      elevation: 4,
                      color: isDaySelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isDaySelected
                                        ? "Total Spent Today"
                                        : "Total Spent This Month",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDaySelected
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                if (isDaySelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${selectedDate.day} ${_monthName(selectedDate.month)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "₹ $totalSpent",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isDaySelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// 🟩 CATEGORIES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (categoryTotals.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${categoryTotals.length}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (categoryTotals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                "No expenses yet",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryTotals.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (context, index) {
                          final category = categoryTotals.keys.elementAt(index);
                          final amount = (categoryTotals[category] as num).toInt();

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(category),
                                      size: 24,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹ $amount",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    /// 🟦 TIMELINE
                    const Text(
                      "Timeline",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 85,
                      child: ListView.builder(
                        controller: _monthScrollController,
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 2 - 71,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final now = DateTime.now();
                          final monthDate = DateTime(now.year, now.month - index, 1);

                          final isSelected = monthDate.month == selectedDate.month &&
                              monthDate.year == selectedDate.year &&
                              !isDaySelected;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildMonthCard(monthDate, isSelected),
                          );
                        },
                      ),
                    ),

                    /// 📅 CALENDAR
                    if (showCalendar) ...[
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CalendarDatePicker(
                            initialDate: selectedDate.isAfter(DateTime.now())
                                ? DateTime.now()
                                : selectedDate.isBefore(DateTime(2020))
                                ? DateTime(2020)
                                : selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                                isDaySelected = true;
                                showCalendar = false;
                              });
                              _loadSummary();
                            },
                            onDisplayedMonthChanged: (date) {
                              setState(() {
                                selectedDate = date;
                                isDaySelected = false;
                              });
                              _loadSummary();
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'bills': return Icons.receipt_long_rounded;
      case 'health': return Icons.medical_services_rounded;
      case 'education': return Icons.school_rounded;
      case 'travel': return Icons.flight_rounded;
      case 'other': return Icons.more_horiz_rounded;
      default: return Icons.category_rounded;
    }
  }

  Widget _buildMonthCard(DateTime monthDate, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected && !isDaySelected) {
          setState(() => showCalendar = !showCalendar);
        } else {
          setState(() {
            selectedDate = monthDate;
            isDaySelected = false;
            showCalendar = false;
          });
          _loadSummary();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
          border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _monthName(monthDate.month),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              monthDate.year.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}