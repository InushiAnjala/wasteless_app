import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../onboarding/login_signup_screen.dart';

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
  final List<String> roles = ["Store Manager", "Chef"];

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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffD4F8D3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: width * 0.90,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 BACK BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginSignupScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Center(
                    child: Text(
                      "Sign Up Here",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Center(
                    child: Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name
                  const Text("Name"),
                  const SizedBox(height: 6),
                  customTextField(
                    controller: nameController,
                    hint: "Enter Name",
                  ),
                  const SizedBox(height: 14),

                  // Role
                  const Text("Role"),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRole,
                        hint: const Text("Select role"),
                        items: roles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
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
                  const SizedBox(height: 14),

                  // NIC
                  const Text("NIC"),
                  const SizedBox(height: 6),
                  customTextField(controller: nicController, hint: "Enter NIC"),
                  const SizedBox(height: 14),

                  // Contact
                  const Text("Contact Number"),
                  const SizedBox(height: 6),
                  customTextField(
                    controller: contactController,
                    hint: "Enter Number",
                  ),
                  const SizedBox(height: 24),

                  // Email
                  const Text("Email"),
                  const SizedBox(height: 6),
                  customTextField(
                    controller: emailController,
                    hint: "Enter Email",
                  ),
                  const SizedBox(height: 14),

                  // Password
                  const Text("Password"),
                  const SizedBox(height: 6),
                  customTextField(
                    controller: passwordController,
                    hint: "Enter Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  const Text("Confirm Password"),
                  const SizedBox(height: 6),
                  customTextField(
                    controller: confirmPasswordController,
                    hint: "Re-enter Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 20),

                  // Terms (UI only)
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (v) {}),
                      const Text("I agree to the terms and conditions"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔥 SIGNUP BUTTON (FIREBASE CONNECTED)
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            selectedRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all required fields"),
                            ),
                          );
                          return;
                        }

                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match"),
                            ),
                          );
                          return;
                        }

                        try {
                          // 1️⃣ Create user in Firebase Auth
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                          String uid = userCredential.user!.uid;

                          // 2️⃣ Save user data in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set({
                                'name': nameController.text.trim(),
                                'role': selectedRole,
                                'nic': nicController.text.trim(),
                                'contact': contactController.text.trim(),
                                'email': emailController.text.trim(),
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Signup successful")),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginSignupScreen(),
                            ),
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message ?? "Signup failed"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Signup"),
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

  // Reusable TextField
  Widget customTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
