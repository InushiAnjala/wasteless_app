import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_food_screen.dart';
import 'food_list_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart';
import 'kitchen_needs_screen.dart';
import '../onboarding/login_signup_screen.dart';
import '../../constants/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onTabSelected});

  final void Function(int index)? onTabSelected;

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
              children: [
                // 🔝 LOGOUT BUTTON (TOP RIGHT, FLOATING)
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

                // ✅ CENTERED TITLE (UNCHANGED STYLE)
                Text("Store Manager", style: AppTextStyles.heading),

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
                      onTabSelected?.call(1);
                    }),
                    const SizedBox(height: 25),

                    menuButton("Notifications", () {
                      onTabSelected?.call(3);
                    }),
                    const SizedBox(height: 25),

                    menuButton("Reports", () {
                      onTabSelected?.call(4);
                    }),
                    const SizedBox(height: 25),

                    menuButton("Kitchen Needs", () {
                      onTabSelected?.call(2);
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
