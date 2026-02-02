import 'package:flutter/material.dart';
import 'home_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA8F5A2), Color(0xFFEFFFF0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ---------------- HEADER ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home_outlined, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    ),
                    Text(
                      "Reports",
                      style: TextStyle(
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined, size: 30),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------------- STAT CARDS GRID ----------------
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _statsCard("Total items", "256", width),
                    _statsCard("Expiring soon", "17", width),
                    _statsCard("Expired", "9", width),
                    _statsCard("Low Stock", "12", width),
                  ],
                ),

                const SizedBox(height: 50),

                // ---------------- SECTION TITLE ----------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Stock Trend Over Time",
                    style: TextStyle(
                      fontSize: width * 0.058,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 120),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Expiry Status Breakdown",
                    style: TextStyle(
                      fontSize: width * 0.058,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  //                    REUSABLE CARD
  // --------------------------------------------------------
  Widget _statsCard(String title, String value, double width) {
    return Container(
      width: width * 0.40,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1, color: Colors.black),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
