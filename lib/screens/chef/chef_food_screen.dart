import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chef_home_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';

class ChefFoodScreen extends StatefulWidget {
  const ChefFoodScreen({super.key});

  @override
  State<ChefFoodScreen> createState() => _ChefFoodScreenState();
}

class _ChefFoodScreenState extends State<ChefFoodScreen> {
  int _currentIndex = 1; // Food List tab
  String searchText = "";
  String selectedCategory = "Veges";
  final List<String> categories = ["Veges", "Meat", "Fruits", "Others"];

  void _handleNav(int index) {
    if (index == _currentIndex) return;
    Widget target;
    switch (index) {
      case 0:
        target = const ChefHomeScreen();
        break;
      case 2:
        target = const NotInStockScreen();
        break;
      case 3:
        target = const AIFoodRecipesScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
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
                _header(),
                const SizedBox(height: 18),
                _searchBar(),
                const SizedBox(height: 16),
                _categoryChips(),
                const SizedBox(height: 16),
                Expanded(child: _foodList()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNav,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Food List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_shopping_cart),
            label: 'Not in stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI Recipes',
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const Icon(Icons.kitchen, color: Color(0xFF1E9E5A), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Food List",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  "Browse by category, search, and mark needs.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
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
            child: const Icon(Icons.list_alt, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        onChanged: (value) => setState(() => searchText = value.toLowerCase()),
      ),
    );
  }

  Widget _categoryChips() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: categories.map(_categoryButton).toList(),
    );
  }

  Widget _categoryButton(String text) {
    final bool isSelected = selectedCategory == text;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

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
          return const Center(child: CircularProgressIndicator());
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

        // Filter out expired items (shown elsewhere) and sort by expiry
        final now = DateTime.now();
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final expiryField = data?["expiryDate"];
          DateTime? expiry;
          if (expiryField is Timestamp) expiry = expiryField.toDate();
          if (expiryField is DateTime) expiry = expiryField;
          if (expiry == null) return true; // keep if no expiry
          final today = DateTime(now.year, now.month, now.day);
          return !expiry.isBefore(today);
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

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>?;

            final String name = (data?["name"] ?? "Unnamed").toString();
            final String amountValue = (data?["amount"] ?? "").toString();
            final String unit = (data?["unit"] ?? "").toString();
            final String amountLabel = amountValue.isNotEmpty
                ? "Amount: $amountValue $unit"
                : "Amount: -";
            final String category = (data?["section"] ?? "").toString();

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
              category: category,
              expiryLabel: expiryText,
              daysLeft: daysLeft,
            );
          },
        );
      },
    );
  }

  Widget _foodCard({
    required String name,
    required String amount,
    required String category,
    required String expiryLabel,
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
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              amount,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        expiryLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Need button placeholder (keeps UI parity with manager view)
          GestureDetector(
            onTap: () => _showNeedDialog(name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF25C06D),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                "Need",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNeedDialog(String itemName) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Need for $itemName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount needed',
              hintText: 'e.g., 5 kg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(context);
                if (value.isEmpty) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Requested $value of $itemName')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
