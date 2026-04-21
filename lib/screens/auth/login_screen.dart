import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../onboarding/login_signup_screen.dart';
import 'forgot_password_screen.dart';
import '../chef/chef_home_screen.dart';
import '../home/main_screen.dart';
import '../admin/admin_home_screen.dart';
import '../../constants/colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      // 1️⃣ Sign in user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // 2️⃣ Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return; // Add check

      if (!userDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User data not found")));
        return;
      }

      String role = userDoc['role'];

      // 3️⃣ Navigate based on role
      if (role == "Chef") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChefHomeScreen()),
        );
      } else if (role == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;

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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: width * 0.92,
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔙 Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginSignupScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Welcome Back",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign in to continue",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Hero(
                      tag: 'onboarding_image',
                      child: Image.asset(
                        "assets/onboarding_3.png",
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    _customTextField(
                      theme: theme,
                      controller: emailController,
                      label: "Email Address",
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _customTextField(
                      theme: theme,
                      controller: passwordController,
                      label: "Password",
                      hint: "Enter your password",
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loginUser,
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightText),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.black45),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
