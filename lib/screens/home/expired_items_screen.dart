import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpiredItemsScreen extends StatelessWidget {
  const ExpiredItemsScreen({super.key});

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
                    "Expired Items",
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
                          return const Center(child: Text("No expired items"));
                        }

                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final docs =
                            snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final expiry = data["expiryDate"];
                              if (expiry is! Timestamp) return false;
                              final expiryDateTime = expiry.toDate();
                              final expiryDate = DateTime(
                                expiryDateTime.year,
                                expiryDateTime.month,
                                expiryDateTime.day,
                              );
                              return expiryDate.isBefore(today);
                            }).toList()..sort((a, b) {
                              final aData = a.data() as Map<String, dynamic>;
                              final bData = b.data() as Map<String, dynamic>;
                              final aExpiry = aData["expiryDate"] as Timestamp;
                              final bExpiry = bData["expiryDate"] as Timestamp;
                              return bExpiry.toDate().compareTo(
                                aExpiry.toDate(),
                              );
                            });

                        if (docs.isEmpty) {
                          return const Center(child: Text("No expired items"));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final name = data["name"] ?? "Item";
                            final amount = _formatAmount(data["amount"]);
                            final unit = data["unit"] ?? "";
                            final expiry = data["expiryDate"] as Timestamp;
                            final expiryDate = expiry.toDate();
                            final dateText =
                                "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}";

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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text("Expired on $dateText"),
                                      ],
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
}
