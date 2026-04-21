import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_signup_screen.dart';
import '../../constants/colors.dart';
import '../../widgets/organic_shape.dart';
import '../../widgets/organic_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // Decorative Organic Shapes
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: OrganicShape(
              width: size.width * 0.9,
              height: size.height * 0.45,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: OrganicShape(
              width: size.width * 0.7,
              height: size.height * 0.35,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO - MATCHES LOGIN SIGNUP STYLE
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 56),

                    // HEADING - PREMIUM TYPOGRAPHY
                    Text(
                      "Welcome to WasteLess",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      "Save food. Save money. Save the planet.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    // GET STARTED BUTTON - ORGANIC STYLE
                    OrganicButton(
                      text: "GET STARTED",
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginSignupScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    
                    Text(
                      "Elevating your sustainable lifestyle.",
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.6),
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
}
