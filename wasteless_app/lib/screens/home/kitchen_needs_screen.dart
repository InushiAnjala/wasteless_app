import 'package:flutter/material.dart';

class KitchenNeedsScreen extends StatelessWidget {
  const KitchenNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Needs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          needItem("Carrot", "Expires in 2 days"),
          needItem("Milk", "Expires tomorrow"),
        ],
      ),
    );
  }

  Widget needItem(String name, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: Colors.green),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }
}
