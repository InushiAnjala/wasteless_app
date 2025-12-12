import 'package:flutter/material.dart';
import 'ai_screen.dart';

class AIRecipeDetailScreen extends StatefulWidget {
  const AIRecipeDetailScreen({super.key});

  @override
  State<AIRecipeDetailScreen> createState() => _AIRecipeDetailScreenState();
}

class _AIRecipeDetailScreenState extends State<AIRecipeDetailScreen> {
  String selectedCategory = "Veg";

  final Map<String, List<Map<String, String>>> foodData = {
    "Veg": [
      {"name": "Carrot", "expiry": "2 days", "amount": "5kg"},
      {"name": "Potato", "expiry": "5 days", "amount": "10kg"},
    ],
    "Meat": [
      {"name": "Chicken", "expiry": "1 day", "amount": "3kg"},
      {"name": "Fish", "expiry": "2 days", "amount": "4kg"},
    ],
    "Fruits": [
      {"name": "Apple", "expiry": "3 days", "amount": "6kg"},
      {"name": "Banana", "expiry": "1 day", "amount": "12kg"},
    ],
    "Others": [
      {"name": "Rice", "expiry": "20 days", "amount": "25kg"},
      {"name": "Milk Powder", "expiry": "10 days", "amount": "8kg"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8FBA8), Color(0xFFEFFEF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // ---------------- TOP BAR ----------------
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const Center(
                      child: Text(
                        "AI Food Recipes",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ---------------- SEARCH BAR ----------------
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, size: 26),
                      hintText: "Search food items",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- CATEGORY BUTTONS ----------------
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      "Veg",
                      "Meat",
                      "Fruits",
                      "Others",
                    ].map((c) => _categoryButton(c)).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------------- FOOD LIST ----------------
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: foodData[selectedCategory]!
                        .map((item) => _foodCard(item))
                        .toList(),
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
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          category,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------- FOOD CARD WIDGET ----------------
  Widget _foodCard(Map<String, String> data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AIScreen(foodName: data["name"] ?? "Unknown"),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"]!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Expires in ${data["expiry"]}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(data["amount"]!, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
