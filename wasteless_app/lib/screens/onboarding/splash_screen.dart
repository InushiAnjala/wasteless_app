import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../widgets/green_button.dart';
import 'get_started_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppAssets.logo, height: 120),
              const SizedBox(height: 20),
              const Text(
                "WasteLess",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Reduce Food Waste, Save Money,\nHelp the Planet",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              GreenButton(
                text: "GET STARTED",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GetStartedScreen(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
