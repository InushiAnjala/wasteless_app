import 'package:flutter/material.dart';
import 'chef_home_screen.dart';
import 'ai_recipe_detail_screen.dart'; // <--- IMPORTANT IMPORT

class AIFoodRecipesScreen extends StatelessWidget {
  const AIFoodRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8FBA8), Color(0xFFEFFEF1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Row(
              children: [
                // HOME ICON
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

                const SizedBox(width: 20),

                // TITLE - CENTERED
                Expanded(
                  child: Center(
                    child: Text(
                      "AI Food Recipes",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8FBA8), Color(0xFFEFFEF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 40),

            // SEARCH BAR
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
                  hintText: "Search for food recipes",
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 50),

            // GENERATE RECIPES BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIRecipeDetailScreen(),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                padding: const EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    "Generate Recipes\n(Near Expiry)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
