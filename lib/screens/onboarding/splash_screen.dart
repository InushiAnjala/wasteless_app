import 'package:flutter/material.dart';
import 'login_signup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8FEC8),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 70),

              /// ⭐ BIG LOGO
              Image.asset("assets/logo.png", height: 320),

              /// ⭐ REAL REDUCED GAP (55 → 30 → NOW 10)
              const SizedBox(height: 10),

              /// ⭐ PARAGRAPH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: "Welcome to "),
                      TextSpan(
                        text: "WasteLess!",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text:
                            "\nTrack your food. reduce\n"
                            "waste and make smarter\n"
                            "choices every day.",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 75),

              /// ⭐ GET STARTED BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginSignupScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF2DAA43), width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        "GET STARTED",
                        style: TextStyle(
                          color: Color(0xFF2DAA43),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 65),
            ],
          ),
        ),
      ),
    );
  }
}
