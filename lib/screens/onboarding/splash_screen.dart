import 'package:flutter/material.dart';
import 'login_signup_screen.dart';
import '../../constants/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),

                          /// ⭐ Premium Logo Container
                          Container(
                            height: size.height * 0.28,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              "assets/logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 40),

                          /// ⭐ Headline
                          Text(
                            "Welcome to WasteLess",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Save food. Save money. Save the planet.",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightText,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 48),

                          /// ⭐ GET STARTED BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginSignupScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "GET STARTED",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
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
            },
          ),
        ),
      ),
    );
  }
}
