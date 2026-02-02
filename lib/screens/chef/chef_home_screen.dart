import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chef_food_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';
import '../onboarding/login_signup_screen.dart';

class ChefHomeScreen extends StatelessWidget {
  const ChefHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌿 Gradient Background
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
              // 🔴 LOGOUT BUTTON (TOP RIGHT)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginSignupScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// ✅ CENTERED TITLE (UNCHANGED)
              const Text(
                "Chef",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 50),

              /// BUTTON 1 – Food List
              _homeButton(
                title: "Food List",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChefFoodScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              /// BUTTON 2 – Not in stocks
              _homeButton(
                title: "Not in stocks",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotInStockScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              /// BUTTON 3 – AI Food Recipes
              _homeButton(
                title: "AI Food Recipies",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIFoodRecipesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable button widget
  Widget _homeButton({required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
