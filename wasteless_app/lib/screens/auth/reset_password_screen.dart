import 'package:flutter/material.dart';
import '../../widgets/text_field.dart';
import '../../widgets/green_button.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reset Password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CustomTextField(hint: "New Password", isPassword: true),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Confirm Password", isPassword: true),
            const SizedBox(height: 30),
            GreenButton(
              text: "Reset",
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
            )
          ],
        ),
      ),
    );
  }
}
