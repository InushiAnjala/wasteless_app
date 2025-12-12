import 'package:flutter/material.dart';
import 'recipe_screen.dart'; // <-- VERY IMPORTANT

class AIScreen extends StatelessWidget {
  final String foodName;

  const AIScreen({super.key, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC8FEC8), Color(0xFFE9FFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ---------------- BACK BUTTON + CENTER TITLE ----------------
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 28,
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

                const SizedBox(height: 20),

                // ---------------- SEARCH BAR ----------------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.black54),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search recipes...",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Recipes using: $foodName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 30),

                _recipeButton(context, "$foodName Soup"),
                const SizedBox(height: 20),

                _recipeButton(context, "$foodName Salad"),
                const SizedBox(height: 20),

                _recipeButton(context, "$foodName Fry"),
                const SizedBox(height: 20),

                _recipeButton(context, "More $foodName Recipes"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recipeButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(recipeName: text),
          ),
        );
      },
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black54),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
