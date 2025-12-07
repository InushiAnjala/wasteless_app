import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';
import '../home/food_list_screen.dart';

class ChefHomeScreen extends StatefulWidget {
  const ChefHomeScreen({super.key});

  @override
  State<ChefHomeScreen> createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  int index = 0;

  final screens = const [
    FoodListScreen(),
    NotInStockScreen(),
    AIFoodRecipesScreen(),
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
