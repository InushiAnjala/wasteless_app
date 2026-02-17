import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_food_screen.dart';
import '../../constants/text_styles.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String selectedCategory = "Veges";
  String searchText = "";

  final List<String> categories = ["Veges", "Meat", "Fruits", "Others"];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.kitchen,
                        color: Color(0xFF1E9E5A),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Food List",
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Keep track by category, search, and edit quickly.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C06D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.list_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search food",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() => searchText = value.toLowerCase());
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Category chips in a single fixed row
                Row(
                  children: categories
                      .map(
                        (category) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: categoryButton(category),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Food list
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("foods")
                        .where("userId", isEqualTo: uid)
                        .where("section", isEqualTo: selectedCategory)
                        .orderBy("expiryDate")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No food items found",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs.where((doc) {
                        final name = (doc["name"] as String).toLowerCase();
                        return name.contains(searchText);
                      }).toList();

                      // Filter out expired items (already covered in reports)
                      final now = DateTime.now();
                      final filtered = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final expiryField = data["expiryDate"];
                        DateTime? expiry;
                        if (expiryField is Timestamp) {
                          expiry = expiryField.toDate();
                        } else if (expiryField is DateTime) {
                          expiry = expiryField;
                        }
                        if (expiry != null) {
                          final today = DateTime(now.year, now.month, now.day);
                          if (expiry.isBefore(today)) return false;
                        }

                        final amount = _parseAmount(data["amount"]);
                        return amount > 0;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            "No matches for your search",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final DateTime expiry =
                              (data["expiryDate"] as Timestamp).toDate();

                          final int daysLeft = expiry
                              .difference(DateTime.now())
                              .inDays;

                          String expiryText;
                          if (daysLeft == 0) {
                            expiryText = "Expires today";
                          } else if (daysLeft == 1) {
                            expiryText = "Expires tomorrow";
                          } else if (daysLeft < 0) {
                            expiryText = "Expired";
                          } else {
                            expiryText = "Expires in $daysLeft days";
                          }

                          return buildFoodBox(
                            docId: doc.id,
                            data: data,
                            expiry: expiryText,
                            daysLeft: daysLeft,
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

  Widget categoryButton(String category) {
    final bool active = selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() => selectedCategory = category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          category,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget buildFoodBox({
    required String docId,
    required Map<String, dynamic> data,
    required String expiry,
    required int daysLeft,
  }) {
    final Color badgeColor;
    final Color badgeText;
    if (daysLeft < 0) {
      badgeColor = const Color(0xFFFFE5E5);
      badgeText = const Color(0xFFD64242);
    } else if (daysLeft <= 2) {
      badgeColor = const Color(0xFFFFF4E3);
      badgeText = const Color(0xFFCC7A00);
    } else {
      badgeColor = const Color(0xFFE7F8EE);
      badgeText = const Color(0xFF1E9E5A);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE7F1EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF1E9E5A),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        expiry,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  "Amount: ${data["amount"]} ${data["unit"]}",
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF1E9E5A)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddFoodScreen(foodId: docId, foodData: data),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD64242),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("foods")
                      .doc(docId)
                      .delete();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
