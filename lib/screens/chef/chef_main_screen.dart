import 'package:flutter/material.dart';
import 'chef_home_screen.dart';
import 'chef_food_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';
import '../home/notifications_screen.dart';

class ChefMainScreen extends StatefulWidget {
  const ChefMainScreen({super.key, this.initialIndex = 0, this.adminMode = false, this.onTabChanged});

  final int initialIndex;
  final bool adminMode;
  final ValueChanged<int>? onTabChanged;

  @override
  State<ChefMainScreen> createState() => _ChefMainScreenState();
}

class _ChefMainScreenState extends State<ChefMainScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      ChefHomeScreen(onTabSelected: _onTabSelected, adminMode: widget.adminMode),
      ChefFoodScreen(adminMode: widget.adminMode),
      NotInStockScreen(adminMode: widget.adminMode),
      NotificationsScreen(adminMode: widget.adminMode),
      AIFoodRecipesScreen(adminMode: widget.adminMode),
    ];
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Material(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: Colors.black38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_rounded),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: 'Restock',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Chef',
            ),
          ],
        ),
      ),
    );
  }
}
