import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_food_screen.dart';
import 'food_list_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart';
import 'kitchen_needs_screen.dart';
import '../onboarding/login_signup_screen.dart';
import '../../constants/text_styles.dart';
import '../../constants/colors.dart';
import '../../widgets/back_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onTabSelected, this.adminMode = false});
  final bool adminMode;
  final void Function(int index)? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = [
      (
        title: 'Add Food',
        subtitle: 'Log items and scan quickly',
        icon: Icons.add_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFoodScreen(adminMode: adminMode)),
          );
        },
      ),
      (
        title: 'Food List',
        subtitle: 'Browse, edit, or search',
        icon: Icons.view_list_rounded,
        onTap: () => onTabSelected?.call(1),
      ),
      (
        title: 'Kitchen Needs',
        subtitle: 'What to buy next',
        icon: Icons.shopping_basket_rounded,
        onTap: () => onTabSelected?.call(2),
      ),
      (
        title: 'Notifications',
        subtitle: 'See alerts and preferences',
        icon: Icons.notifications_rounded,
        onTap: () => onTabSelected?.call(3),
      ),
      (
        title: 'Reports',
        subtitle: 'Track waste and trends',
        icon: Icons.analytics_rounded,
        onTap: () => onTabSelected?.call(4),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.15),
              colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminMode ? 'Admin Portal' : 'Store Manager',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            'Welcome back to WasteLess',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                      if (!adminMode)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
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
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Your Kitchen',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track, reduce waste, and save money every day.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.eco_rounded, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: menuButton(
                          context,
                          item.title,
                          item.subtitle,
                          item.icon,
                          item.onTap,
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: colorScheme.primary),
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
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.lightText.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
