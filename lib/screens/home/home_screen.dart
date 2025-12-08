import 'package:flutter/material.dart';
import 'add_food_screen.dart';
import 'food_list_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart'; // ⭐ ADD THIS
import 'kitchen_needs_screen.dart'; // ⭐ AND THIS

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
                    menuButton("Add food", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFoodScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    menuButton("Food List", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodListScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    menuButton("Notifications", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    // ⭐ REPORTS BUTTON → reports_screen.dart
                    menuButton("Reports", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),

                    // ⭐ KITCHEN NEEDS BUTTON → kitchen_needs_screen.dart
                    menuButton("Kitchen Needs", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KitchenNeedsScreen(),
                        ),
                      );
                    }),
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
