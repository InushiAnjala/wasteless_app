import 'package:flutter/material.dart';
import 'add_food_screen.dart';
import 'food_list_screen.dart';
import 'notifications_screen.dart'; // <-- IMPORT THIS

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌿 Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB8F8B8), Color(0xFFF2FFF2)],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Store Manager",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                // Buttons list
                Column(
                  children: [
                    // ADD FOOD BUTTON → opens AddFoodScreen
                    menuButton("Add food", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFoodScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    // FOOD LIST BUTTON → opens FoodListScreen
                    menuButton("Food List", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodListScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    // NOTIFICATIONS BUTTON → opens NotificationsScreen
                    menuButton("Notifications", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    menuButton("Reports", () {}),
                    const SizedBox(height: 25),

                    menuButton("Kitchen Needs", () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
