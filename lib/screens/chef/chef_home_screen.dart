import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chef_food_screen.dart';
import 'not_in_stock_screen.dart';
import 'ai_food_recipes_screen.dart';
import '../onboarding/login_signup_screen.dart';
import '../home/notifications_screen.dart';
import '../../constants/colors.dart';

class ChefHomeScreen extends StatefulWidget {
  final bool adminMode;
  final void Function(int index)? onTabSelected;
  const ChefHomeScreen({super.key, this.adminMode = false, this.onTabSelected});

  @override
  State<ChefHomeScreen> createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WasteLess Chef',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Kitchen Management',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                    if (!widget.adminMode)
                      IconButton.filledTonal(
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
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
            ),

            // Hero Card
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, const Color(0xFF1B8E34)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome back, Chef!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to cook something amazing today?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Menu Options
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _menuButton(
                    theme: theme,
                    title: 'Kitchen Inventory',
                    subtitle: 'Browse & manage current food items',
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      if (widget.onTabSelected != null) {
                        widget.onTabSelected!(1);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChefFoodScreen(adminMode: widget.adminMode)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _menuButton(
                    theme: theme,
                    title: 'Out of Stock',
                    subtitle: 'Items that need urgent restock',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    onTap: () {
                      if (widget.onTabSelected != null) {
                        widget.onTabSelected!(2);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotInStockScreen(adminMode: widget.adminMode)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _menuButton(
                    theme: theme,
                    title: 'Notifications',
                    subtitle: 'Stay ahead of expiries and alerts',
                    icon: Icons.notifications_active_rounded,
                    iconColor: Colors.green,
                    onTap: () {
                      if (widget.onTabSelected != null) {
                        widget.onTabSelected!(3);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationsScreen(adminMode: widget.adminMode)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _menuButton(
                    theme: theme,
                    title: 'AI Chef Assistant',
                    subtitle: 'Generate recipes from your items',
                    icon: Icons.auto_awesome_rounded,
                    iconColor: Colors.deepPurpleAccent,
                    onTap: () {
                      if (widget.onTabSelected != null) {
                        widget.onTabSelected!(4);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AIFoodRecipesScreen(adminMode: widget.adminMode)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
