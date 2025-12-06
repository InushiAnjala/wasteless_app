import 'package:flutter/material.dart';
import 'ai_food_recipe_detail_screen.dart';

class AIFoodRecipesScreen extends StatelessWidget {
  const AIFoodRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Food Recipes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          recipeCard(
            context,
            "Carrot Cake",
            "You have carrots expiring in 2 days",
          ),
          recipeCard(
            context,
            "Green Veggie Soup",
            "Spinach + carrots available",
          ),
          recipeCard(
            context,
            "Tomato Pasta",
            "You have tomatoes low in stock",
          ),
        ],
      ),
    );
  }

  Widget recipeCard(BuildContext context, String title, String subtitle) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AIFoodRecipeDetailScreen(
            recipeName: title,
            ingredientsNote: subtitle,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.green),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
