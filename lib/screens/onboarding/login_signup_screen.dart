import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF2), // Brand Light Green
      body: Stack(
        children: [
          // Decorative Organic Shapes (Brighter Green)
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _organicShape(
              width: size.width * 0.9,
              height: size.height * 0.45,
              color: const Color(0xFF3CB371).withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: _organicShape(
              width: size.width * 0.7,
              height: size.height * 0.35,
              color: const Color(0xFF3CB371).withOpacity(0.08),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO - BIGGER & PROMINENT
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3CB371).withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 140, // Increased size
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // HEADING
                    Text(
                      "WasteLess",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32), // Vibrant Dark Green
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      "Your journey to a sustainable kitchen.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 17,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // PRIMARY ACTION (Vibrant Green)
                    _organicButton(
                      text: "Login",
                      isPrimary: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SECONDARY ACTION
                    _organicButton(
                      text: "Sign Up",
                      isPrimary: false,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                    
                    Text(
                      "Making a difference, together.",
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3CB371).withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _organicShape({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }

  Widget _organicButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF3CB371) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF3CB371),
          elevation: isPrimary ? 12 : 0,
          shadowColor: const Color(0xFF3CB371).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isPrimary 
                ? BorderSide.none 
                : const BorderSide(color: Color(0xFF3CB371), width: 2),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.rubik(
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
