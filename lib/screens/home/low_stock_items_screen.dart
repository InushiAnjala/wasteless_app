import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LowStockItemsScreen extends StatelessWidget {
  const LowStockItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8F5A3), Color(0xFFE7FFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Low Stock Items",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: user == null
                  ? const Center(child: Text("Please sign in to view items"))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("foods")
                          .where("userId", isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No low stock items"),
                          );
                        }

                        final allDocs = snapshot.data!.docs;
                        final Map<String, Map<String, dynamic>> maxByName = {};
                        for (final doc in allDocs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (!_hasValidAmount(data)) continue;
                          final name = (data["name"] as String?) ?? doc.id;
                          final amount = _amountToDouble(data["amount"]);
                          final current = maxByName[name];
                          if (current == null ||
                              amount > _amountToDouble(current["amount"])) {
                            maxByName[name] = data;
                          }
                        }

                        final docs = maxByName.entries.where((entry) {
                          final amount = _amountToDouble(entry.value["amount"]);
                          return amount <= 2;
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text("No low stock items"),
                          );
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].value;
                            final name = data["name"] ?? "Item";
                            final amount = _formatAmount(data["amount"]);
                            final unit = data["unit"] ?? "";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$amount $unit",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount is int) return amount.toString();
    if (amount is double) {
      if (amount == amount.roundToDouble()) {
        return amount.toInt().toString();
      }
      return amount.toString();
    }
    return amount?.toString() ?? "";
  }

  double _amountToDouble(dynamic amount) {
    if (amount is num) return amount.toDouble();
    if (amount is String) return double.tryParse(amount) ?? 0;
    return 0;
  }

  bool _hasValidAmount(Map<String, dynamic> data) {
    final value = data["amount"];
    if (value is num) return true;
    if (value is String) return double.tryParse(value) != null;
    return false;
  }
}
