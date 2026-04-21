import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../widgets/organic_shape.dart';
import '../../widgets/organic_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent! Please check your email."),
          backgroundColor: Colors.green,
        ),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // Decorative Organic Shapes (Consistent with LoginScreen)
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: OrganicShape(
              width: size.width * 0.8,
              height: size.height * 0.4,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.1,
            child: OrganicShape(
              width: size.width * 0.6,
              height: size.height * 0.3,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: size.width * 0.92,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 🔙 Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton.filledTonal(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Forgot Password",
                        style: GoogleFonts.playfairDisplay(
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We'll help you get back in",
                        style: GoogleFonts.rubik(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.lightText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Image.asset(
                        "assets/onboarding_1.png",
                        height: 180,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 40),

                      // Email Field (Consistent Style)
                      _customTextField(
                        theme: theme,
                        controller: emailController,
                        label: "Email Address",
                        hint: "Enter your registered email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 40),

                      // Action Button
                      OrganicButton(
                        text: _isLoading ? "Sending..." : "Send Reset Link",
                        onPressed: _isLoading ? () {} : _resetPassword,
                      ),

                      const SizedBox(height: 16),
                      
                      Text(
                        "Check your inbox for further instructions.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          textStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.lightText.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.black45),
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
