import 'package:flutter/material.dart';
import 'recipe_screen.dart'; // <-- VERY IMPORTANT
import '../../constants/colors.dart';

class AIScreen extends StatelessWidget {
  final String foodName;

  const AIScreen({super.key, required this.foodName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onBack: () => Navigator.pop(context),
                  foodName: foodName,
                ),
                const SizedBox(height: 24),
                _SearchCard(foodName: foodName),
                const SizedBox(height: 24),
                _QuickTags(foodName: foodName),
                const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Recipe Studio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Creative ideas for $foodName',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatefulWidget {
  final String foodName;

  const _SearchCard({required this.foodName});

  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeScreen(recipeText: query.trim())),
    );
  }

  void _submitCustomSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    // Combine what the user typed with the selected ingredients
    _submitSearch('$query using ${widget.foodName}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _submitCustomSearch(),
                    decoration: InputDecoration(
                      hintText: 'What can we cook with ${widget.foodName}?',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black38,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitCustomSearch,
                  icon: const Icon(Icons.send_rounded),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                text: 'Soup',
                onTap: () => _submitSearch('${widget.foodName} soup'),
              ),
              _Chip(
                text: 'Salad',
                onTap: () => _submitSearch('${widget.foodName} salad'),
              ),
              _Chip(
                text: 'Quick Fry',
                onTap: () => _submitSearch('${widget.foodName} fry'),
              ),
              _Chip(
                text: 'See All',
                onTap: () => _submitSearch('More ${widget.foodName} ideas'),
              ),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Recommended for You',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _Pill(
                text: 'Fresh Ideas',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(
                      recipeText: 'Fresh recipe ideas for $foodName',
                    ),
                  ),
                ),
              ),
              _Pill(
                text: 'Under 15m',
                icon: Icons.timer_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(
                      recipeText: 'Quick $foodName recipes under 15 minutes',
                    ),
                  ),
                ),
              ),
              _Pill(
                text: 'Healthy',
                icon: Icons.favorite_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeScreen(recipeText: 'Healthy $foodName recipes'),
                  ),
                ),
              ),
              _Pill(
                text: 'Zero Waste',
                icon: Icons.eco_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(
                      recipeText: 'Zero waste cooking ideas for $foodName',
                    ),
                  ),
                ),
              ),
            ],
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
      'Hearty $foodName Soup',
      'Garden Fresh $foodName Salad',
      'Sizzling $foodName Stir-fry',
      'Roasted $foodName Bowl',
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _RecipeCard(
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
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RecipeCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-generated zero waste recipe',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.lightText.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _Pill({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
