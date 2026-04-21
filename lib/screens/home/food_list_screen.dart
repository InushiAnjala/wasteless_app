import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_food_screen.dart';
import '../../constants/text_styles.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key, this.adminMode = false});

  final bool adminMode;

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String selectedCategory = "Veges";
  String searchText = "";

  List<String> get categories => ["Veges", "Meat", "Fruits", "Others"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.kitchen_rounded, color: colorScheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Food Inventory",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              "Manage your kitchen stock",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Search bar
                TextField(
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Search food items...",
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchText = value.toLowerCase());
                  },
                ),

                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _categoryChip(theme, categories[index]),
                  ),
                ),

                const SizedBox(height: 20),

                // Food list
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: (() {
                      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection("foods");
                      if (!widget.adminMode) {
                        query = query
                            .where("section", isEqualTo: selectedCategory)
                            .where("userId", isEqualTo: uid);
                      }
                      return query.snapshots();
                    })(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text("No food items found", style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot<Object?>> docs = snapshot.data!.docs;
                      if (widget.adminMode) {
                        final cat = selectedCategory.toLowerCase();
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final section = (data['section'] ?? '').toString().toLowerCase();
                          return section == cat;
                        }).toList();
                      }
                      docs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data["name"] as String).toLowerCase();
                        return name.contains(searchText);
                      }).toList();

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

                      // Sort in memory to avoid Firestore index requirement
                      filtered.sort((a, b) {
                        final da = a.data() as Map<String, dynamic>;
                        final db = b.data() as Map<String, dynamic>;
                        final ea = (da['expiryDate'] as Timestamp?)?.toDate();
                        final eb = (db['expiryDate'] as Timestamp?)?.toDate();
                        if (ea == null && eb == null) return 0;
                        if (ea == null) return 1;
                        if (eb == null) return -1;
                        return ea.compareTo(eb);
                      });

                      if (filtered.isEmpty) {
                        return Center(child: Text("No matches for search", style: TextStyle(color: Colors.grey[400])));
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final DateTime expiry = (data["expiryDate"] as Timestamp).toDate();
                          final int daysLeft = expiry.difference(DateTime.now()).inDays;

                          String expiryText = daysLeft == 0 ? "Today" : daysLeft == 1 ? "Tomorrow" : "$daysLeft days";
                          return _foodCard(theme, doc.id, data, expiryText, daysLeft);
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

  Widget _categoryChip(ThemeData theme, String category) {
    final bool active = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _foodCard(ThemeData theme, String docId, Map<String, dynamic> data, String expiry, int daysLeft) {
    final Color badgeColor = daysLeft <= 2 ? Colors.orangeAccent : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.restaurant_rounded, color: badgeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"],
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("${data["amount"]} ${data["unit"]}", style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "Expires in $expiry",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddFoodScreen(foodId: docId, foodData: data))),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () async => await FirebaseFirestore.instance.collection("foods").doc(docId).delete(),
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
