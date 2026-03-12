import 'package:flutter/material.dart';
import 'chef_home_screen.dart';
import 'chef_food_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_recipe_detail_screen.dart';
import 'ai_screen.dart';
import 'recipe_screen.dart';

class AIFoodRecipesScreen extends StatefulWidget {
  const AIFoodRecipesScreen({super.key});

  @override
  State<AIFoodRecipesScreen> createState() => _AIFoodRecipesScreenState();
}

class _AIFoodRecipesScreenState extends State<AIFoodRecipesScreen> {
  int _currentIndex = 3; // AI Recipes tab
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allRecipes = const [
    'Pasta Soup',
    'Pasta Salad',
    'Pasta Fry',
    'Chicken Curry',
    'Grilled Chicken',
    'Fish Tacos',
    'Veggie Stir Fry',
    'Tomato Basil Soup',
    'Mushroom Risotto',
    'Beef Stew',
    'Paneer Butter Masala',
    'Caesar Salad',
    'Avocado Toast',
    'Lemon Garlic Shrimp',
    'Egg Fried Rice',
    'Tofu Teriyaki',
    'Chickpea Curry',
    'Spinach Lasagna',
    'Pumpkin Soup',
    'Berry Smoothie',
  ];

  List<String> _filtered = const [];
  bool _showSuggestions = false;

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
      case 2:
        target = const NotInStockScreen();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type something to search recipes')),
      );
      return;
    }

    _openRecipe(query);
  }

  void _openRecipe(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeScreen(recipeText: name)),
    );
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onQueryChanged(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filtered = const [];
        _showSuggestions = false;
      });
      return;
    }

    final results = _allRecipes
        .where((r) => r.toLowerCase().contains(query))
        .take(10)
        .toList();

    setState(() {
      _filtered = results;
      _showSuggestions = results.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

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
                          Icons.auto_awesome,
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
                              "AI food recipes",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Search or generate recipes from your ingredients.",
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

                // Search bar
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black87),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search for food recipes",
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 16),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => _submitSearch(),
                                onChanged: _onQueryChanged,
                              ),
                            ),
                            IconButton(
                              onPressed: _submitSearch,
                              icon: const Icon(Icons.arrow_forward),
                              color: const Color(0xFF25C06D),
                            ),
                          ],
                        ),
                        if (_showSuggestions) ...[
                          const SizedBox(height: 10),
                          Flexible(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 220),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0E9E3)),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFE7F1EA),
                                ),
                                itemBuilder: (_, index) {
                                  final suggestion = _filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    onTap: () => _openRecipe(suggestion),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Generate recipes button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIRecipeDetailScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25C06D),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Generate recipes\n(Near expiry)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
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
}
