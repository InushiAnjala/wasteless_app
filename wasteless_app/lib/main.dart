import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/onboarding/splash_screen.dart';

void main() {
  runApp(const WasteLessApp());
}

class WasteLessApp extends StatelessWidget {
  const WasteLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WasteLess",
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgColor,
        primaryColor: AppColors.primary,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
