import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8F5A3), Color(0xFFE7FFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------- TOP ROW: BACK BUTTON + TITLE ----------------
            Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Colors.black,
                  ),
                ),

                // Center Title
                Expanded(
                  child: Center(
                    child: const Text(
                      "Your Notifications",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Spacer to balance Row (same width as back button)
                const SizedBox(width: 30),
              ],
            ),

            const SizedBox(height: 35),

            // ---------------- NOTIFICATION CARDS ----------------
            buildNotificationCard("Carrot Expires in 2 days, 5kg"),
            const SizedBox(height: 20),

            buildNotificationCard(""),
            const SizedBox(height: 20),

            buildNotificationCard(""),
            const SizedBox(height: 20),

            buildNotificationCard(""),
          ],
        ),
      ),
    );
  }

  // ---------- CARD WIDGET ----------
  Widget buildNotificationCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        text.isEmpty ? " " : text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
