import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/text_styles.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const int _expiringSoonDays = 3;
  static const double _lowStockThreshold = 2.0;

  DateTime? _getExpiryDate(Map<String, dynamic> data) {
    final value = data["expiryDate"];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  double _getAmount(Map<String, dynamic> data) {
    final value = data["amount"];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA8F5A2), Color(0xFFEFFFF0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ---------------- HEADER ----------------
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text("Reports", style: AppTextStyles.heading),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined, size: 30),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------------- STATS + TREND ----------------
                Builder(
                  builder: (context) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      return const Text("Please sign in to view reports");
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("foods")
                          .where("userId", isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Failed to load reports");
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        final now = DateTime.now();

                        int total = docs.length;
                        int expiringSoon = 0;
                        int expired = 0;
                        int lowStock = 0;

                        for (final doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final expiry = _getExpiryDate(data);
                          if (expiry != null) {
                            final daysLeft = expiry.difference(now).inDays;
                            if (daysLeft < 0) {
                              expired++;
                            } else if (daysLeft <= _expiringSoonDays) {
                              expiringSoon++;
                            }
                          }

                          final amount = _getAmount(data);
                          if (amount <= _lowStockThreshold) {
                            lowStock++;
                          }
                        }

                        final trendPoints = _monthlyTrendPoints(docs);

                        return Column(
                          children: [
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.center,
                              children: [
                                _statsCard("Total items", "$total", width),
                                _statsCard(
                                  "Expiring soon",
                                  "$expiringSoon",
                                  width,
                                ),
                                _statsCard("Expired", "$expired", width),
                                _statsCard("Low Stock", "$lowStock", width),
                              ],
                            ),

                            const SizedBox(height: 40),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Stock Trend Over Time",
                                style: TextStyle(
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _TrendChart(points: trendPoints),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Expiry Status Breakdown",
                    style: TextStyle(
                      fontSize: width * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  //                    REUSABLE CARD
  // --------------------------------------------------------
  Widget _statsCard(String title, String value, double width) {
    return Container(
      width: width * 0.40,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1, color: Colors.black),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ), // Adjusted font size for better UI consistency
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ), // Adjusted font size for better UI consistency
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  //                 STOCK TREND (LAST 6 MONTHS)
  // --------------------------------------------------------
  List<_TrendPoint> _monthlyTrendPoints(List<QueryDocumentSnapshot> docs) {
    // Build a timeline for the last 6 months including current.
    final now = DateTime.now();
    final List<DateTime> months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - 5 + i, 1),
    );

    final Map<String, double> counts = {
      for (final m in months) _monthKey(m): 0,
    };

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiry = _getExpiryDate(data);
      if (expiry == null) continue;
      final key = _monthKey(DateTime(expiry.year, expiry.month, 1));
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return months
        .map(
          (m) => _TrendPoint(
            label: DateFormat('MMM').format(m),
            value: counts[_monthKey(m)] ?? 0,
          ),
        )
        .toList();
  }

  String _monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
}

class _TrendPoint {
  const _TrendPoint({required this.label, required this.value});
  final String label;
  final double value;
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Text('No data yet');
    }

    final maxY =
        (points.map((p) => p.value).fold<double>(0, (a, b) => a > b ? a : b) +
                1)
            .clamp(1, double.infinity)
            .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            horizontalInterval: (maxY / 4).clamp(1, double.infinity).toDouble(),
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: (maxY / 4).clamp(1, double.infinity).toDouble(),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= points.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      points[idx].label,
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].value),
              ],
              isCurved: true,
              color: Colors.green.shade600,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.shade100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
