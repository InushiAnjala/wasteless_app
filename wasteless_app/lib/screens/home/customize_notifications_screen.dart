import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';

class CustomizeNotificationsScreen extends StatelessWidget {
  const CustomizeNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Vegetables (days before expiry)"),
            Slider(value: 2, onChanged: (_) {}, min: 1, max: 7),
            const SizedBox(height: 20),

            const Text("Fruits (days before expiry)"),
            Slider(value: 3, onChanged: (_) {}, min: 1, max: 7),
            const SizedBox(height: 20),

            const Text("Others (days before expiry)"),
            Slider(value: 5, onChanged: (_) {}, min: 1, max: 10),
            const SizedBox(height: 40),

            GreenButton(text: "Save", onPressed: () {})
          ],
        ),
      ),
    );
  }
}
