import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter OTP",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text(
              "We sent a 6-digit OTP to your email.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => Container(
                  width: 45,
                  height: 55,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "-",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GreenButton(
              text: "Verify",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResetPasswordScreen(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
