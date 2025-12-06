import 'package:flutter/material.dart';

class AIFoodRecipeDetailScreen extends StatelessWidget {
  final String recipeName;
  final String ingredientsNote;

  const AIFoodRecipeDetailScreen({
    super.key,
    required this.recipeName,
    required this.ingredientsNote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ingredientsNote,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text("- 2 cups carrots"),
            const Text("- 1 cup milk"),
            const Text("- 1 tbsp sugar"),
            const SizedBox(height: 20),

            const Text(
              "Instructions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "1. Wash and chop the carrots.\n"
              "2. Mix with milk and cook for 20 minutes.\n"
              "3. Add sugar and blend.\n"
              "4. Allow to cool and serve.",
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
