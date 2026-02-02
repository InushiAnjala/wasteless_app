import 'package:flutter/material.dart';
import 'chef_home_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    // Filter list based on category
    List<FoodItem> filteredFoods = foods
        .where((item) => item.category.toLowerCase() == selectedCategory)
        .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA8F5A2), Color(0xFFEFFFEF)],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // ----------------------------------------------------------
              // TOP BAR
              // ----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChefHomeScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.home, size: 32),
                    ),
                    const Spacer(),
                    const Text(
                      "Food List",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert, size: 28),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // SEARCH BAR
              // ----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // CATEGORY BUTTONS
              // ----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _categoryButton("Veg", "veg"),
                    _categoryButton("Meat", "meat"),
                    _categoryButton("Fruits", "fruits"),
                    _categoryButton("Others", "others"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // FOOD LIST
              // ----------------------------------------------------------
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: _foodCard(food),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: isSelected ? 3 : 2),
          color: isSelected ? Colors.green.shade100 : Colors.white,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(item.expiry, style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    Text(item.quantity, style: const TextStyle(fontSize: 16)),
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
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text("Need", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
