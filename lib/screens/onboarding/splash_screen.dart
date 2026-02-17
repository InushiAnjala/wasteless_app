import 'package:flutter/material.dart';
import 'login_signup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC8FEC8), Color(0xFFEFFFF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 80, // match login box height with margins
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45),
                        border: Border.all(color: const Color(0xFF2DAA43), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.02),

                          /// ⭐ BIG LOGO (responsive height)
                          Image.asset(
                            "assets/logo.png",
                            height: size.height * 0.30,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 24),

                          /// ⭐ Headline
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 21,
                                  height: 1.45,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(text: "Welcome to "),
                                  TextSpan(
                                    text: "WasteLess!",
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  TextSpan(
                                    text: "\nSave food. Save money.",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          const SizedBox(height: 28),

                          /// ⭐ GET STARTED BUTTON
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2DAA43), Color(0xFF1C8E34)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.20),
                                      blurRadius: 16,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "GET STARTED",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_ios,
                                          color: Colors.white, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
