import 'package:flutter/material.dart';
import 'home_screen.dart'; // ← UPDATE your_app_name

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String selectedCategory = "Veg";

  // Example food data for demo
  final Map<String, List<Map<String, String>>> foodData = {
    "Veg": [
      {"name": "Carrot", "expiry": "Expires in 2 days", "amount": "5kg"},
      {"name": "Potato", "expiry": "Expires in 5 days", "amount": "10kg"},
    ],
    "Meat": [
      {"name": "Chicken", "expiry": "Expires tomorrow", "amount": "3kg"},
      {"name": "Beef", "expiry": "Expires in 3 days", "amount": "4kg"},
    ],
    "Fruits": [
      {"name": "Apple", "expiry": "Expires in 4 days", "amount": "2kg"},
      {"name": "Banana", "expiry": "Expires tomorrow", "amount": "1.5kg"},
    ],
    "Others": [
      {"name": "Bread", "expiry": "Expires today", "amount": "4 units"},
      {"name": "Eggs", "expiry": "Expires in 6 days", "amount": "12"},
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
            colors: [Color(0xFFA0F5A0), Color(0xFFF2FFF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -----------------------------------------------------------------
                // TOP BAR (HOME LEFT + TITLE CENTERED)
                // -----------------------------------------------------------------
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.home, size: 30),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Food List",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // CATEGORY BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    categoryButton("Veg"),
                    categoryButton("Meat"),
                    categoryButton("Fruits"),
                    categoryButton("Others"),
                  ],
                ),

                const SizedBox(height: 15),

                // FOOD LIST
                Expanded(
                  child: ListView(
                    children: foodData[selectedCategory]!
                        .map((food) => buildFoodBox(food))
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

  // -----------------------------------------------------------------------
  // CATEGORY BUTTON
  // -----------------------------------------------------------------------
  Widget categoryButton(String category) {
    bool active = selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // FOOD BOX
  // -----------------------------------------------------------------------
  Widget buildFoodBox(Map<String, String> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            food["name"]!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(food["expiry"]!, style: const TextStyle(fontSize: 16)),
              Text(
                food["amount"]!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
