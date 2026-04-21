import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../onboarding/login_signup_screen.dart';
import '../../constants/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final nameController = TextEditingController();
  final nicController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Dropdown
  String? selectedRole;
  final List<String> roles = ["Store Manager", "Chef", "Admin"];

  bool _agreedToTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    nicController.dispose();
    contactController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔙 BACK BUTTON
                    IconButton.filledTonal(
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

                    const SizedBox(height: 24),

                    Text(
                      "Create Account",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join the waste-less revolution",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Inputs Section
                    _sectionTitle(theme, "Account Details"),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: nameController,
                      label: "Full Name",
                      hint: "Enter your name",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _customDropdown(theme),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: nicController,
                      label: "NIC Number",
                      hint: "Enter NIC",
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: contactController,
                      label: "Contact",
                      hint: "Enter phone number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle(theme, "Security"),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: emailController,
                      label: "Email Address",
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: passwordController,
                      label: "Password",
                      hint: "Create a password",
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    _customTextField(
                      theme: theme,
                      controller: confirmPasswordController,
                      label: "Confirm Password",
                      hint: "Repeat password",
                      icon: Icons.lock_clock_outlined,
                      obscure: true,
                    ),

                    const SizedBox(height: 24),

                    // Terms
                    InkWell(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) => setState(
                                  () => _agreedToTerms = v ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "I agree to the Terms & Conditions",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.lightText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SIGNUP BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
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

  Widget _customDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Role",
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRole,
              isExpanded: true,
              hint: const Text("Select your role"),
              items: roles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role, style: theme.textTheme.bodyMedium),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        selectedRole == null ||
        !_agreedToTerms) {
      _showSnackBar("Please fill all required fields and accept terms");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'role': selectedRole,
        'nic': nicController.text.trim(),
        'contact': contactController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnackBar("Signup successful!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? "Signup failed");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
