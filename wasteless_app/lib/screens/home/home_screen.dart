import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import 'add_food_screen.dart';
import 'food_list_screen.dart';
import 'notifications_screen.dart';
import 'kitchen_needs_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final screens = const [
    FoodListScreen(),
    AddFoodScreen(),
    NotificationsScreen(),
    KitchenNeedsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNav(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}
