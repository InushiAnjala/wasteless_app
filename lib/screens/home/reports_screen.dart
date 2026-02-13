import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

                // ---------------- STAT CARDS GRID ----------------
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

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            _statsCard("Total items", "$total", width),
                            _statsCard("Expiring soon", "$expiringSoon", width),
                            _statsCard("Expired", "$expired", width),
                            _statsCard("Low Stock", "$lowStock", width),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 50),

                // ---------------- SECTION TITLE ----------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Stock Trend Over Time",
                    style: TextStyle(
                      fontSize:
                          width *
                          0.055, // Adjusted font size for better UI consistency
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 120),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Expiry Status Breakdown",
                    style: TextStyle(
                      fontSize:
                          width *
                          0.055, // Adjusted font size for better UI consistency
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
}
