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
            colors: [Color(0xFFB7F5C7), Color(0xFFEFFDF3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.green,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Reports",
                        style: AppTextStyles.heading.copyWith(fontSize: 24),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.download_outlined, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- STATS + TREND ----------------
                Expanded(
                  child: Builder(
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

                          // Track best (highest effective) amount per item name
                          // to keep low-stock count aligned with the sheet.
                          final Map<String, double> bestAmountByName = {};

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
                            final effectiveAmount =
                                (expiry != null && expiry.isBefore(now))
                                ? 0.0
                                : amount;

                            final rawName = (data['name'] as String?) ?? 'Item';
                            final key = rawName.trim().toLowerCase();
                            final current = bestAmountByName[key];
                            if (current == null || effectiveAmount > current) {
                              bestAmountByName[key] = effectiveAmount;
                            }
                          }

                          final lowStock = bestAmountByName.values
                              .where((v) => v <= _lowStockThreshold)
                              .length;

                          final trendPoints = _monthlyTrendPoints(docs);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _statsCard(
                                      "Total items",
                                      "$total",
                                      width,
                                      color: Colors.green.shade600,
                                      icon: Icons.inventory_2_rounded,
                                    ),
                                    _statsCard(
                                      "Expiring soon",
                                      "$expiringSoon",
                                      width,
                                      color: Colors.orange.shade600,
                                      icon: Icons.timer_outlined,
                                    ),
                                    _statsCard(
                                      "Expired",
                                      "$expired",
                                      width,
                                      color: Colors.red.shade600,
                                      icon: Icons.warning_amber_rounded,
                                      onTap: () =>
                                          _showExpiredSheet(context, docs),
                                    ),
                                    _statsCard(
                                      "Low Stock",
                                      "$lowStock",
                                      width,
                                      color: Colors.blueGrey.shade700,
                                      icon: Icons.water_drop_outlined,
                                      onTap: () =>
                                          _showLowStockSheet(context, docs),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                _sectionHeader(
                                  label: "Stock Trend Over Time",
                                  icon: Icons.show_chart_rounded,
                                ),

                                const SizedBox(height: 16),

                                _TrendChart(points: trendPoints),

                                const SizedBox(height: 32),

                                _sectionHeader(
                                  label: "Expiry Status Breakdown",
                                  icon: Icons.pie_chart_rounded,
                                ),

                                const SizedBox(height: 16),

                                _ExpiryPie(
                                  expired: expired.toDouble(),
                                  expiringSoon: expiringSoon.toDouble(),
                                  fresh: (total - expired - expiringSoon)
                                      .clamp(0, total)
                                      .toDouble(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
  Widget _statsCard(
    String title,
    String value,
    double width, {
    VoidCallback? onTap,
    Color? color,
    IconData? icon,
  }) {
    final bg = (color ?? Colors.green).withOpacity(0.12);
    final fg = color ?? Colors.green;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: width * 0.42,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: fg.withOpacity(0.35), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon ?? Icons.bar_chart_rounded, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({required String label, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
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

  Future<void> _showExpiredSheet(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) async {
    final now = DateTime.now();
    final Map<DateTime, List<_ExpiredItem>> grouped = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiry = _getExpiryDate(data);
      if (expiry == null || !expiry.isBefore(now)) continue;
      final key = DateTime(expiry.year, expiry.month, 1);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(
        _ExpiredItem(
          name: (data['name'] as String?) ?? 'Item',
          amount: _getAmount(data),
          unit: (data['unit'] as String?) ?? '',
          expiry: expiry,
        ),
      );
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // latest first

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        if (keys.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'No expired items yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Items that have passed their expiry date will appear here.',
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              initialChildSize: 0.7,
              builder: (_, controller) {
                return ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: keys.length,
                  itemBuilder: (_, index) {
                    final key = keys[index];
                    final items = grouped[key]!;
                    items.sort((a, b) => a.expiry.compareTo(b.expiry));

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == keys.length - 1 ? 0 : 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(key),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Expired on ${DateFormat('dd MMM').format(item.expiry)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${item.amount.toStringAsFixed(0)} ${item.unit}',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLowStockSheet(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) async {
    final now = DateTime.now();

    // Deduplicate by item name (case-insensitive, across sections) keeping the
    // highest amount so stale low entries elsewhere do not keep an item flagged.
    final Map<String, _LowStockItem> bestByName = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = _getAmount(data);
      final expiry = _getExpiryDate(data);

      // Expired items count as zero to force them into low stock.
      final effectiveAmount = (expiry != null && expiry.isBefore(now))
          ? 0.0
          : amount;

      final section = (data['section'] as String?) ?? 'Others';
      final rawName = (data['name'] as String?) ?? 'Item';
      final nameKey = rawName.trim().toLowerCase();
      final current = bestByName[nameKey];
      if (current == null || effectiveAmount > current.amount) {
        bestByName[nameKey] = _LowStockItem(
          name: rawName,
          amount: effectiveAmount,
          unit: (data['unit'] as String?) ?? '',
          section: section,
          expiry: expiry,
        );
      }
    }

    final Map<String, List<_LowStockItem>> grouped = {
      'Veges': [],
      'Fruits': [],
      'Meat': [],
      'Others': [],
    };

    for (final item in bestByName.values) {
      if (item.amount > _lowStockThreshold) continue;
      final section = item.section;
      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(item);
    }

    final sections = grouped.entries.where((e) => e.value.isNotEmpty).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        if (sections.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'No low-stock items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text('Items below the low-stock threshold will appear here.'),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              initialChildSize: 0.7,
              builder: (_, controller) {
                return ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: sections.length,
                  itemBuilder: (_, index) {
                    final entry = sections[index];
                    final items = entry.value;

                    items.sort((a, b) {
                      // Sort by expiry soonest first; nulls last.
                      if (a.expiry == null && b.expiry == null) return 0;
                      if (a.expiry == null) return 1;
                      if (b.expiry == null) return -1;
                      return a.expiry!.compareTo(b.expiry!);
                    });

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == sections.length - 1 ? 0 : 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${item.amount.toStringAsFixed(0)} ${item.unit}',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TrendPoint {
  const _TrendPoint({required this.label, required this.value});
  final String label;
  final double value;
}

class _ExpiredItem {
  const _ExpiredItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.expiry,
  });

  final String name;
  final double amount;
  final String unit;
  final DateTime expiry;
}

class _LowStockItem {
  const _LowStockItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.section,
    this.expiry,
  });

  final String name;
  final double amount;
  final String unit;
  final String section;
  final DateTime? expiry;
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
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

class _ExpiryPie extends StatelessWidget {
  const _ExpiryPie({
    required this.expired,
    required this.expiringSoon,
    required this.fresh,
  });

  final double expired;
  final double expiringSoon;
  final double fresh;

  @override
  Widget build(BuildContext context) {
    final total = expired + expiringSoon + fresh;
    if (total <= 0) {
      return const Text('No data yet');
    }

    final sections = [
      _slice('Expired', expired, Colors.red.shade500),
      _slice('Expiring soon', expiringSoon, Colors.orange.shade600),
      _slice('Fresh', fresh, Colors.green.shade600),
    ].where((s) => s.value > 0).toList();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 50,
              sections: [
                for (final s in sections)
                  PieChartSectionData(
                    color: s.color,
                    value: s.value,
                    title: '${((s.value / total) * 100).round()}%',
                    radius: 64,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final s in sections)
              _LegendDot(label: s.label, color: s.color),
          ],
        ),
      ],
    );
  }

  _PieSlice _slice(String label, double value, Color color) {
    return _PieSlice(label: label, value: value, color: color);
  }
}

class _PieSlice {
  const _PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
