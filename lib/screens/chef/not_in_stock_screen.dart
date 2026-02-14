import 'package:flutter/material.dart';
import 'chef_home_screen.dart';
import 'chef_food_screen.dart';
import 'ai_food_recipes_screen.dart';

class NotInStockScreen extends StatefulWidget {
  const NotInStockScreen({super.key});

  @override
  State<NotInStockScreen> createState() => _NotInStockScreenState();
}

class _NotInStockScreenState extends State<NotInStockScreen> {
  int _currentIndex = 2; // Not in stock tab

  // Controllers for three rows
  final List<TextEditingController> nameControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );

  final List<TextEditingController> amountControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );

  void _handleNav(int index) {
    if (index == _currentIndex) return;
    Widget target;
    switch (index) {
      case 0:
        target = const ChefHomeScreen();
        break;
      case 1:
        target = const ChefFoodScreen();
        break;
      case 3:
        target = const AIFoodRecipesScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C06D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.remove_shopping_cart,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Not in stock",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Track what needs replenishing and quantities.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Entry card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE7F1EA)),
                  ),
                  child: Column(
                    children: [
                      _editableRow(1, 0),
                      const Divider(height: 22, color: Color(0xFFE6EAE7)),
                      _editableRow(2, 1),
                      const Divider(height: 22, color: Color(0xFFE6EAE7)),
                      _editableRow(3, 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNav,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Food List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_shopping_cart),
            label: 'Not in stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI Recipes',
          ),
        ],
      ),
    );
  }

  // ROW UI — Name + Amount
  Widget _editableRow(int number, int index) {
    return Row(
      children: [
        Text(
          "$number.",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 20),

        // Name Field
        Expanded(
          flex: 2,
          child: TextField(
            controller: nameControllers[index],
            decoration: const InputDecoration(
              hintText: "Item name",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(width: 10),

        const Text("|", style: TextStyle(fontSize: 18, color: Colors.black45)),

        const SizedBox(width: 10),

        // Amount Field
        Expanded(
          flex: 3,
          child: TextField(
            controller: amountControllers[index],
            decoration: const InputDecoration(
              hintText: "Amount needed",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
