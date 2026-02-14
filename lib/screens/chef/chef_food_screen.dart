import 'package:flutter/material.dart';
import 'chef_home_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';

// ---------------------------------------
// FOOD DATA MODEL
// ---------------------------------------
class FoodItem {
  final String name;
  final String expiry;
  final String quantity;
  final String category; // veg, meat, fruits, others

  FoodItem({
    required this.name,
    required this.expiry,
    required this.quantity,
    required this.category,
  });
}

// ---------------------------------------
// MAIN SCREEN
// ---------------------------------------
class ChefFoodScreen extends StatefulWidget {
  const ChefFoodScreen({super.key});

  @override
  State<ChefFoodScreen> createState() => _ChefFoodScreenState();
}

class _ChefFoodScreenState extends State<ChefFoodScreen> {
  int _currentIndex = 1; // Food List tab
  String searchText = "";

  // ---------------------------------------
  // FOOD DATA LIST
  // ---------------------------------------
  final List<FoodItem> foods = [
    FoodItem(
      name: "Carrot",
      expiry: "Expires in 2 days",
      quantity: "15kg",
      category: "veg",
    ),
    FoodItem(
      name: "Tomato",
      expiry: "Expires in 3 days",
      quantity: "10kg",
      category: "veg",
    ),
    FoodItem(
      name: "Chicken",
      expiry: "Expires in 1 day",
      quantity: "8kg",
      category: "meat",
    ),
    FoodItem(
      name: "Mango",
      expiry: "Expires in 5 days",
      quantity: "12kg",
      category: "fruits",
    ),
    FoodItem(
      name: "Salt",
      expiry: "Always available",
      quantity: "20kg",
      category: "others",
    ),
  ];

  String selectedCategory = "veg";

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
    // Filter list based on category
    List<FoodItem> filteredFoods = foods
        .where((item) => item.category.toLowerCase() == selectedCategory)
        .where((item) => item.name.toLowerCase().contains(searchText))
        .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Background Gradient
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
                          children: const [
                            Text(
                              "Food List",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Browse by category, search, and mark needs.",
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

                // Category chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _categoryButton("Veges", "veg"),
                    _categoryButton("Meat", "meat"),
                    _categoryButton("Fruits", "fruits"),
                    _categoryButton("Others", "others"),
                  ],
                ),

                const SizedBox(height: 16),

                // Food list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: filteredFoods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      return _foodCard(food);
                    },
                  ),
                ),
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

  // ----------------------------------------------------------
  // CATEGORY BUTTON WIDGET
  // ----------------------------------------------------------
  Widget _categoryButton(String text, String value) {
    bool isSelected = selectedCategory == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // FOOD CARD WIDGET
  // ----------------------------------------------------------
  Widget _foodCard(FoodItem item) {
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
          // TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item.expiry,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.quantity,
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

          const SizedBox(width: 15),

          // "Need" BUTTON
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF25C06D),
              borderRadius: BorderRadius.circular(10),
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
        ],
      ),
    );
  }
}
