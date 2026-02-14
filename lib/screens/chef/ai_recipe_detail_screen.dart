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
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.16),
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
                              color: Colors.green.withOpacity(0.22),
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
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search food items",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Category chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    "Veges",
                    "Meat",
                    "Fruits",
                    "Others",
                  ].map((c) => _categoryButton(c)).toList(),
                ),

                const SizedBox(height: 16),

                // Food list
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
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF25C06D).withOpacity(0.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF25C06D)
                : const Color(0xFFCEDFD3),
            width: 1.4,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1E9E5A) : Colors.black87,
          ),
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
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: const Color(0xFFE7F1EA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Expires in ${data["expiry"]}",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    data["amount"]!,
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
      ),
    );
  }
}
