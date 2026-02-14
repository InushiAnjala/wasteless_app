import 'package:flutter/material.dart';
import '../../constants/text_styles.dart';

class KitchenNeedsScreen extends StatefulWidget {
  const KitchenNeedsScreen({Key? key}) : super(key: key);

  @override
  State<KitchenNeedsScreen> createState() => _KitchenNeedsScreenState();
}

class _KitchenNeedsScreenState extends State<KitchenNeedsScreen> {
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C06D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.kitchen,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kitchen Needs",
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Quick check of items to buy or consume soon.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ---------- FIRST ITEM ----------
                _itemCard(
                  title: "Carrot",
                  subtitle: "Expires in 2 days",
                  amount: "5kg",
                  value: check1,
                  onChanged: (val) => setState(() => check1 = val!),
                ),
                const SizedBox(height: 16),

                // ---------- EMPTY ITEMS ----------
                _itemCardEmpty(
                  value: check2,
                  onChanged: (v) => setState(() => check2 = v!),
                ),
                const SizedBox(height: 12),
                _itemCardEmpty(
                  value: check3,
                  onChanged: (v) => setState(() => check3 = v!),
                ),

                const SizedBox(height: 26),

                // ---------- NOT IN STOCK PANEL ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE7F1EA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCF6E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.remove_shopping_cart,
                              size: 18,
                              color: Color(0xFF1E9E5A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Not in Stocks",
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _stockRow(1, "Name", "Amount"),
                      const Divider(height: 18, color: Color(0xFFE6EFE8)),
                      _stockRow(2, "Name", "Amount"),
                      const Divider(height: 18, color: Color(0xFFE6EFE8)),
                      _stockRow(3, "Name", "Amount"),
                    ],
                  ),
                ),

                const SizedBox(height: 34),
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
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7F1EA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, // Adjusted font size for better UI
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15),
                    ), // Adjusted font size for better UI
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E9E5A),
                        ),
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
            activeColor: const Color(0xFF1E9E5A),
            side: const BorderSide(color: Color(0xFF1E9E5A), width: 1.6),
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
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7F1EA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
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
            activeColor: const Color(0xFF1E9E5A),
            side: const BorderSide(color: Color(0xFF1E9E5A), width: 1.6),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ), // Adjusted font size for better UI
        ),
        const SizedBox(width: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 15, // Adjusted font size for better UI
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 15, // Adjusted font size for better UI
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
