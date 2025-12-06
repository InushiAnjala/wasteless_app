import 'package:flutter/material.dart';
import '../../widgets/text_field.dart';
import '../../widgets/green_button.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const CustomTextField(hint: "Email"),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Password", isPassword: true),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GreenButton(
              text: "Login",
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
