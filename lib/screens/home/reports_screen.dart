import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/report_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.adminMode = false});

  final bool adminMode;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  String _selectedRange = "All";
  DateTime? _customStart;
  DateTime? _customEnd;

  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
        _selectedRange = "Custom";
      });
    }
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Analytics",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              widget.adminMode
                                  ? "Global System Statistics"
                                  : "Insights & Statistics",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Generating PDF report..."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            await ReportService.generateAndDownloadReport(
                              context,
                              adminMode: widget.adminMode,
                              userId: user.uid,
                              timeRange: _selectedRange,
                              customStart: _customStart,
                              customEnd: _customEnd,
                            );
                          }
                        },
                        icon: const Icon(Icons.file_download_rounded),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Premium Filter Bar (Glassmorphism-like)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            "All",
                            "7 Days",
                            "1 Month",
                            "4 Months",
                            "Custom",
                          ].map((range) {
                            final isSelected = _selectedRange == range;
                            String label = range;
                            if (range == "Custom" &&
                                _customStart != null &&
                                _customEnd != null) {
                              label =
                                  "${DateFormat('MMM d').format(_customStart!)} - ${DateFormat('MMM d').format(_customEnd!)}";
                            }
                            return GestureDetector(
                              onTap: () {
                                if (range == "Custom") {
                                  _selectCustomRange();
                                } else {
                                  setState(() {
                                    _selectedRange = range;
                                    _customStart = null;
                                    _customEnd = null;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.lightText,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
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
                        stream: (() {
                          Query<Map<String, dynamic>> query = FirebaseFirestore
                              .instance
                              .collection("foods");
                          if (!widget.adminMode) {
                            query = query.where("userId", isEqualTo: user.uid);
                          }
                          return query.snapshots();
                        })(),
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

                          final allDocs = snapshot.data?.docs ?? [];
                          final now = DateTime.now();

                          // Filter docs based on selected range
                          final docs = allDocs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final createdAt = data['createdAt'];

                            if (_selectedRange == "All") return true;
                            if (createdAt == null) {
                              return false; // Hide old items in specific ranges
                            }

                            final createdDate = (createdAt as Timestamp)
                                .toDate();

                            if (_selectedRange == "Custom" &&
                                _customStart != null &&
                                _customEnd != null) {
                              final start = DateTime(
                                _customStart!.year,
                                _customStart!.month,
                                _customStart!.day,
                              );
                              final end = DateTime(
                                _customEnd!.year,
                                _customEnd!.month,
                                _customEnd!.day,
                                23,
                                59,
                                59,
                              );
                              return createdDate.isAfter(
                                    start.subtract(const Duration(seconds: 1)),
                                  ) &&
                                  createdDate.isBefore(
                                    end.add(const Duration(seconds: 1)),
                                  );
                            }

                            final difference = now
                                .difference(createdDate)
                                .inDays;
                            if (_selectedRange == "7 Days") {
                              return difference <= 7;
                            }
                            if (_selectedRange == "1 Month") {
                              return difference <= 30;
                            }
                            if (_selectedRange == "4 Months") {
                              return difference <= 120;
                            }

                            return true;
                          }).toList();

                          int total = docs.length;
                          int expiringSoon = 0;
                          int expired = 0;

                          // Track best (highest effective) amount per item name
                          // to keep low-stock count aligned with the sheet.
                          final Map<String, double> bestAmountByName = {};

                          for (final doc in docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final expiry = _getExpiryDate(data);
                            final amount = _getAmount(data);
                            if (expiry != null) {
                              final daysLeft = expiry.difference(now).inDays;
                              if (daysLeft < 0) {
                                if (amount > 0) {
                                  expired++; // count only if remaining
                                }
                              } else if (daysLeft <= _expiringSoonDays) {
                                expiringSoon++;
                              }
                            }

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

                          // Advanced Sustainability Score Calculation
                          double sustainabilityScore = total == 0
                              ? 100
                              : ((total - expired) / total) * 100;

                          // Category Distribution Calculation
                          Map<String, int> categoryCounts = {};
                          for (final doc in docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final section =
                                data['section'] as String? ?? 'Others';
                            categoryCounts[section] =
                                (categoryCounts[section] ?? 0) + 1;
                          }

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                // Sustainability Score Card
                                _sustainabilityCard(
                                  colorScheme,
                                  sustainabilityScore,
                                  total,
                                  expired,
                                ),

                                const SizedBox(height: 24),

                                _sectionHeader(
                                  label: "Key Metrics",
                                  icon: Icons.dashboard_customize_rounded,
                                ),

                                const SizedBox(height: 16),

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

                                const SizedBox(height: 32),

                                // Smart Insight Card
                                _smartInsightCard(
                                  colorScheme,
                                  docs,
                                  expired,
                                  expiringSoon,
                                ),

                                const SizedBox(height: 32),

                                _sectionHeader(
                                  label: "Stock Trend Over Time",
                                  icon: Icons.show_chart_rounded,
                                  subtitle:
                                      "X-Axis: Months | Y-Axis: Number of items scheduled to expire.",
                                ),

                                const SizedBox(height: 16),

                                _TrendChart(points: trendPoints),

                                const SizedBox(height: 32),

                                _sectionHeader(
                                  label: "Category Distribution",
                                  icon: Icons.bar_chart_rounded,
                                  subtitle:
                                      "Compares the amount of stock across your kitchen categories.",
                                ),

                                const SizedBox(height: 16),

                                _CategoryDistributionChart(
                                  categoryCounts: categoryCounts,
                                ),

                                const SizedBox(height: 32),

                                _sectionHeader(
                                  label: "Expiry Status Breakdown",
                                  icon: Icons.pie_chart_rounded,
                                  subtitle:
                                      "Current ratio of Fresh, Expiring Soon, and Expired items.",
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
    final bg = (color ?? Colors.green).withValues(alpha: 0.12);
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
          border: Border.all(color: fg.withValues(alpha: 0.35), width: 1),
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

  Widget _sectionHeader({
    required String label,
    required IconData icon,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: subtitle,
                triggerMode: TooltipTriggerMode.tap,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------------
  //                 NEW ADVANCED WIDGETS
  // --------------------------------------------------------

  Widget _sustainabilityCard(
    ColorScheme colorScheme,
    double score,
    int total,
    int expired,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                "${score.round()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kitchen Health",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 80
                      ? "Excellent Waste Control!"
                      : score >= 50
                      ? "Doing Good, Keep it Up!"
                      : "Needs Attention",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniIndicator(Icons.check_circle_outline, "$total Total"),
                    const SizedBox(width: 12),
                    _miniIndicator(
                      Icons.eco_outlined,
                      "${total - expired} Fresh",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniIndicator(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _smartInsightCard(
    ColorScheme colorScheme,
    List<QueryDocumentSnapshot> docs,
    int expired,
    int expiringSoon,
  ) {
    String message =
        "Your inventory is looking great! Try to consume items before they expire.";
    IconData icon = Icons.lightbulb_outline_rounded;
    Color color = Colors.blue;

    if (expired > 5) {
      message =
          "High waste detected this period. Consider buying smaller portions of frequently expired items.";
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (expiringSoon > 3) {
      message =
          "You have several items expiring soon. Perfect time for a 'kitchen-sink' stew!";
      icon = Icons.auto_awesome_rounded;
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Insights",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
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
      final amount = _getAmount(data);
      if (amount <= 0) continue; // Skip items consumed before expiry
      final key = DateTime(expiry.year, expiry.month, 1);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(
        _ExpiredItem(
          name: (data['name'] as String?) ?? 'Item',
          amount: amount,
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            horizontalInterval: (maxY / 4).clamp(1, double.infinity).toDouble(),
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade100, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                "Item Count",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: (maxY / 4).clamp(1, double.infinity).toDouble(),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      points[idx].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
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
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: AppColors.primary,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 40,
                sections: [
                  for (final s in sections)
                    PieChartSectionData(
                      color: s.color,
                      value: s.value,
                      title: '${((s.value / total) * 100).round()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final s in sections)
                _LegendDot(label: s.label, color: s.color),
            ],
          ),
        ],
      ),
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

class _CategoryDistributionChart extends StatelessWidget {
  final Map<String, int> categoryCounts;
  const _CategoryDistributionChart({required this.categoryCounts});

  @override
  Widget build(BuildContext context) {
    if (categoryCounts.isEmpty) {
      return const Center(child: Text("No category data available"));
    }

    final entries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = entries.first.value.toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: entries.map((e) {
          final percentage = e.value / maxCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "${e.value} items",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
