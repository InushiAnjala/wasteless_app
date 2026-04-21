import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/main_screen.dart';
import '../chef/chef_main_screen.dart';
import '../onboarding/login_signup_screen.dart';
import '../../constants/colors.dart';
import '../../widgets/back_button.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context, theme),
                const SizedBox(height: 32),
                _card(
                  context,
                  theme: theme,
                  title: 'Store Manager Portal',
                  subtitle: 'View and manage all store data',
                  icon: Icons.store_rounded,
                  color: colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _AdminManagerPortal(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  context,
                  theme: theme,
                  title: 'Chef Assistant Portal',
                  subtitle: 'Access all cooking & recipe features',
                  icon: Icons.restaurant_menu_rounded,
                  color: const Color(0xFF1E9E5A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _AdminChefPortal(),
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Admin Elevated Access',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.admin_panel_settings_rounded,
                color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Hub',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'Central System Control',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _card(
    BuildContext context, {
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 26),
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
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black12, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Keeps manager portal navigation on a separate route so the system back
/// button returns to the admin hub instead of exiting the app.
class _AdminManagerPortal extends StatefulWidget {
  const _AdminManagerPortal();

  @override
  State<_AdminManagerPortal> createState() => _AdminManagerPortalState();
}

class _AdminManagerPortalState extends State<_AdminManagerPortal> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: MainScreen(
        adminMode: true,
        onTabChanged: (index) => setState(() => _currentTabIndex = index),
      ),
    );
  }
}

/// Chef portal wrapper for the same back behavior.
class _AdminChefPortal extends StatefulWidget {
  const _AdminChefPortal();

  @override
  State<_AdminChefPortal> createState() => _AdminChefPortalState();
}

class _AdminChefPortalState extends State<_AdminChefPortal> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: ChefMainScreen(
        adminMode: true,
        onTabChanged: (index) => setState(() => _currentTabIndex = index),
      ),
    );
  }
}
