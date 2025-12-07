import 'package:flutter/material.dart';
import 'home_screen.dart';

class KitchenNeedsNotification extends StatefulWidget {
  const KitchenNeedsNotification({super.key});

  @override
  State<KitchenNeedsNotification> createState() =>
      _KitchenNeedsNotificationState();
}

class _KitchenNeedsNotificationState extends State<KitchenNeedsNotification> {
  // Checkbox states
  bool check1 = false;
  bool check2 = false;
  bool check3 = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA8F5A2), Color(0xFFEFFFF0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ---------- HEADER ----------
                Row(
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
                    Expanded(
                      child: Center(
                        child: Text(
                          "Kitchen Needs",
                          style: TextStyle(
                            fontSize: width * 0.075,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // keeps symmetry for home icon
                  ],
                ),

                const SizedBox(height: 25),

                // ---------- FIRST FILLED CARD ----------
                _itemCard(
                  title: "Carrot",
                  subtitle: "Expires in 2 days",
                  amount: "5kg",
                  value: check1,
                  onChanged: (val) => setState(() => check1 = val!),
                ),

                const SizedBox(height: 18),

                // ---------- EMPTY CARDS ----------
                _itemCardEmpty(
                  value: check2,
                  onChanged: (v) => setState(() => check2 = v!),
                ),
                const SizedBox(height: 18),
                _itemCardEmpty(
                  value: check3,
                  onChanged: (v) => setState(() => check3 = v!),
                ),

                const SizedBox(height: 30),

                // ---------- NOT IN STOCK PANEL ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Not in Stocks",
                        style: TextStyle(
                          fontSize: width * 0.065,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _stockRow(1, "Name", "Amount"),
                      const SizedBox(height: 12),
                      _stockRow(2, "Name", "Amount"),
                      const SizedBox(height: 12),
                      _stockRow(3, "Name", "Amount"),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================
  //              ITEM CARD (FILLED)
  // ===========================================

  Widget _itemCard({
    required String title,
    required String subtitle,
    required String amount,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(subtitle, style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        Transform.scale(
          scale: 1.4,
          child: Checkbox(
            value: value,
            shape: const CircleBorder(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ===========================================
  //              ITEM CARD (EMPTY)
  // ===========================================

  Widget _itemCardEmpty({
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: 1.4,
          child: Checkbox(
            value: value,
            shape: const CircleBorder(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ===========================================
  //                STOCK ROW
  // ===========================================

  Widget _stockRow(int index, String name, String amount) {
    return Row(
      children: [
        Text(
          "$index.",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
