import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_screen.dart';

class AIRecipeDetailScreen extends StatefulWidget {
  const AIRecipeDetailScreen({super.key});

  @override
  State<AIRecipeDetailScreen> createState() => _AIRecipeDetailScreenState();
}

class _AIRecipeDetailScreenState extends State<AIRecipeDetailScreen> {
  String selectedCategory = "Veges";
  String searchText = "";
  // Track selected food items
  final Set<String> _selectedFoods = {};
  void _toggleFoodSelection(String name) {
    setState(() {
      if (_selectedFoods.contains(name)) {
        _selectedFoods.remove(name);
      } else {
        _selectedFoods.add(name);
      }
    });
  }

  void _generateMultiFoodRecipe() {
    if (_selectedFoods.length < 2) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIScreen(foodName: _selectedFoods.join(", ")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card with back
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.arrow_back,
                            size: 26,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C06D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "AI Food Recipes",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Pick a category and see ideas.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
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
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search food items",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) =>
                        setState(() => searchText = value.toLowerCase()),
                  ),
                ),

                const SizedBox(height: 16),

                // Category chips (single row)
                Row(
                  children: ["Veges", "Meat", "Fruits", "Others"]
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _categoryButton(c),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Food list
                Expanded(child: _foodList()),

                // Multi-select generate button
                if (_selectedFoods.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25C06D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _generateMultiFoodRecipe,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        "Generate recipe with ${_selectedFoods.length} items",
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

  // ---------------- CATEGORY BUTTON WIDGET ----------------
  Widget _categoryButton(String category) {
    bool isSelected = category == selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          category,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1E9E5A) : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ---------------- FOOD LIST QUERY AND FILTERING ----------------
  Widget _foodList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("foods")
          .where("section", isEqualTo: selectedCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final msg = snapshot.error?.toString() ?? "Unable to load foods";
          return Center(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF25C06D)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No food items found",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs.where((doc) {
          final map = doc.data() as Map<String, dynamic>?;
          final name = (map?["name"] ?? "").toString().toLowerCase();
          return name.contains(searchText);
        }).toList();

        final now = DateTime.now();
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final expiryField = data?["expiryDate"];
          DateTime? expiry;
          if (expiryField is Timestamp) expiry = expiryField.toDate();
          if (expiryField is DateTime) expiry = expiryField;
          if (expiry != null) {
            final today = DateTime(now.year, now.month, now.day);
            if (expiry.isBefore(today)) return false;
          }

          final amount = _parseAmount(data?["amount"]);
          return amount > 0;
        }).toList();

        filtered.sort((a, b) {
          DateTime? ea;
          DateTime? eb;
          final da = a.data() as Map<String, dynamic>?;
          final db = b.data() as Map<String, dynamic>?;
          final ra = da?["expiryDate"];
          final rb = db?["expiryDate"];
          if (ra is Timestamp) ea = ra.toDate();
          if (ra is DateTime) ea = ra;
          if (rb is Timestamp) eb = rb.toDate();
          if (rb is DateTime) eb = rb;
          if (ea == null && eb == null) return 0;
          if (ea == null) return 1;
          if (eb == null) return -1;
          return ea.compareTo(eb);
        });

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "No matches for your search",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>?;

            final String name = (data?["name"] ?? "Unnamed").toString();
            final dynamic amountField = data?["amount"];
            final String unit = (data?["unit"] ?? "").toString();
            final String amountLabel = _formatAmount(amountField, unit);

            final dynamic expiryField = data?["expiryDate"];
            DateTime? expiry;
            if (expiryField is Timestamp) {
              expiry = expiryField.toDate();
            } else if (expiryField is DateTime) {
              expiry = expiryField;
            }

            int daysLeft;
            String expiryText;
            if (expiry == null) {
              daysLeft = 9999;
              expiryText = "No expiry set";
            } else {
              daysLeft = expiry.difference(DateTime.now()).inDays;
              if (daysLeft == 0) {
                expiryText = "Expires today";
              } else if (daysLeft == 1) {
                expiryText = "Expires tomorrow";
              } else if (daysLeft < 0) {
                expiryText = "Expired";
              } else {
                expiryText = "Expires in $daysLeft days";
              }
            }

            return _foodCard(
              name: name,
              amount: amountLabel,
              expiryLabel: expiryText,
              isSelected: _selectedFoods.contains(name),
              onSelect: () => _toggleFoodSelection(name),
              onTap: () {
                // Single-tap: go to single-item recipe
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIScreen(foodName: name),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------- FOOD CARD WIDGET ----------------
  Widget _foodCard({
    required String name,
    required String amount,
    required String expiryLabel,
    bool isSelected = false,
    VoidCallback? onSelect,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isSelected ? Colors.green : const Color(0xFFE7F1EA),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (onSelect != null) onSelect();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          expiryLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatAmount(dynamic value, String unit) {
    final numeric = _parseAmount(value);
    if (numeric > 0) {
      final display = numeric % 1 == 0
          ? numeric.toInt().toString()
          : numeric.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return 'Amount: $display ${unit.trim()}'.trim();
    }
    return '';
  }
}
