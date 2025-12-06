import 'package:flutter/material.dart';

class NotInStockScreen extends StatelessWidget {
  const NotInStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Not In Stock"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          missingItem("Carrot", "Expired 2 days ago"),
          missingItem("Tomatoes", "Expired yesterday"),
          missingItem("Spinach", "Out of stock"),
        ],
      ),
    );
  }

  Widget missingItem(String food, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(status, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
