import 'package:flutter/material.dart';
import '../../widgets/text_field.dart';
import '../../widgets/green_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sign Up",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CustomTextField(hint: "Full Name"),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Email"),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Password", isPassword: true),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Confirm Password", isPassword: true),
            const SizedBox(height: 30),
            GreenButton(
              text: "Create Account",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
