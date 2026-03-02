import 'package:flutter/material.dart';
import 'recipe_screen.dart'; // <-- VERY IMPORTANT

class AIScreen extends StatelessWidget {
  final String foodName;

  const AIScreen({super.key, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC8FEC8), Color(0xFFE9FFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onBack: () => Navigator.pop(context),
                  foodName: foodName,
                ),
                const SizedBox(height: 18),
                _SearchCard(foodName: foodName),
                const SizedBox(height: 14),
                _QuickTags(foodName: foodName),
                const SizedBox(height: 14),
                Expanded(child: _RecipeList(foodName: foodName)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final String foodName;

  const _Header({required this.onBack, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFE9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 22,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Food Recipes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ideas using $foodName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF72C472),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final String foodName;

  const _SearchCard({required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search recipes...',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.45)),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF72C472),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Find',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(text: '$foodName soup'),
              _Chip(text: '$foodName salad'),
              _Chip(text: '$foodName fry'),
              _Chip(text: 'More $foodName ideas'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTags extends StatelessWidget {
  final String foodName;

  const _QuickTags({required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Recommended',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Pill(text: 'Fresh $foodName'),
                _Pill(text: 'Veges'),
                _Pill(text: '15 min'),
                _Pill(text: 'Low prep'),
                _Pill(text: 'Trending'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeList extends StatelessWidget {
  final String foodName;

  const _RecipeList({required this.foodName});

  @override
  Widget build(BuildContext context) {
    final recipes = <String>[
      '$foodName Soup',
      '$foodName Salad',
      '$foodName Fry',
      'More $foodName Recipes',
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      itemBuilder: (context, index) => _RecipeCard(
        title: recipes[index],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeText: recipes[index]),
            ),
          );
        },
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: recipes.length,
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RecipeCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFE9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dining, color: Colors.black87),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Balanced ingredients and minimal waste ideas.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FFE9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF72C472).withOpacity(0.45)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
