import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../../constants/colors.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

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
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                  // LOGO
                  Image.asset(
                    'assets/logo.png',
                    height: size.height * 0.22,
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Join WasteLess",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ready to make a difference?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightText,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
