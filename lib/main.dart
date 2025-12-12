import 'package:flutter/material.dart';
import 'package:wasteless_app/screens/auth/forgot_password_screen.dart';
import 'package:wasteless_app/screens/auth/login_screen.dart';
import 'package:wasteless_app/screens/auth/otp_screen.dart';
import 'package:wasteless_app/screens/auth/reset_password_screen.dart';
import 'package:wasteless_app/screens/auth/signup_screen.dart';
import 'package:wasteless_app/screens/chef/ai_food_recipes_screen.dart';
import 'package:wasteless_app/screens/chef/ai_recipe_detail_screen.dart';
import 'package:wasteless_app/screens/chef/ai_screen.dart';
import 'package:wasteless_app/screens/chef/chef_food_screen.dart';
import 'package:wasteless_app/screens/chef/chef_home_screen.dart';
import 'package:wasteless_app/screens/chef/not_in_stock_screen.dart';
import 'package:wasteless_app/screens/chef/recipe_screen.dart';
import 'package:wasteless_app/screens/home/add_food_screen.dart';
import 'package:wasteless_app/screens/home/customize_notifications_screen.dart';
import 'package:wasteless_app/screens/home/food_list_screen.dart';
import 'package:wasteless_app/screens/home/home_screen.dart';
import 'package:wasteless_app/screens/home/kitchen_needs_screen.dart';
import 'package:wasteless_app/screens/home/notifications_screen.dart';
import 'package:wasteless_app/screens/home/reports_screen.dart';
import 'package:wasteless_app/screens/onboarding/login_signup_screen.dart';
import 'package:wasteless_app/widgets/bottom_nav.dart';
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
      home: const ChefHomeScreen(),
    );
  }
}
