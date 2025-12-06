import 'package:flutter/material.dart';
import '../../widgets/text_field.dart';
import '../../widgets/green_button.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Forgot Password",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text(
              "Enter your email and we will send you an OTP",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const CustomTextField(hint: "Email"),
            const SizedBox(height: 30),
            GreenButton(
              text: "Continue",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OtpScreen()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
