import 'package:flutter/material.dart';

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

                const Text(
                  "AI Food Recipes",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

                _recipeButton("$foodName Soup"),
                const SizedBox(height: 20),

                _recipeButton("$foodName Salad"),
                const SizedBox(height: 20),

                _recipeButton("$foodName Fry"),
                const SizedBox(height: 20),

                _recipeButton("More $foodName Recipes"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recipeButton(String text) {
    return Container(
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
    );
  }
}
