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
    final items = [
      (
        title: 'Add food',
        subtitle: 'Log items and scan quickly',
        icon: Icons.add_circle_outline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodScreen()),
          );
        },
      ),
      (
        title: 'Food List',
        subtitle: 'Browse, edit, or search',
        icon: Icons.list_alt,
        onTap: () => onTabSelected?.call(1),
      ),
      (
        title: 'Notifications',
        subtitle: 'See alerts and preferences',
        icon: Icons.notifications_active_outlined,
        onTap: () => onTabSelected?.call(3),
      ),
      (
        title: 'Reports',
        subtitle: 'Track waste and trends',
        icon: Icons.bar_chart_outlined,
        onTap: () => onTabSelected?.call(4),
      ),
      (
        title: 'Kitchen Needs',
        subtitle: 'What to buy next',
        icon: Icons.shopping_bag_outlined,
        onTap: () => onTabSelected?.call(2),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB8F8B8), Color(0xFFF2FFF2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                // Top row with logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text('Store Manager', style: AppTextStyles.heading),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginSignupScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hero card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.14),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF25C06D),
                        child: Icon(Icons.store, color: Colors.white, size: 22),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hello!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'What do you want to manage today?',
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Menu cards without scrolling
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: menuButton(
                            item.title,
                            item.subtitle,
                            item.icon,
                            item.onTap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F8EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1E9E5A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
