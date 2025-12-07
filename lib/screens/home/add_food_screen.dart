import 'package:flutter/material.dart';
import 'home_screen.dart'; // ← UPDATE THIS

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  String? selectedSection;
  String? selectedAmount;

  final List<String> sectionList = ["Veges", "Fruits", "Meat", "Others"];
  final List<String> amountUnits = ["Kg", "L", "Unit"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0F5A0),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),

        title: const Text(
          "Add Food",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION ----------------------------------------------------------
            const Text("Section", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            _buildDropdown(
              value: selectedSection,
              hint: "Select Section",
              items: sectionList,
              onChanged: (v) => setState(() => selectedSection = v),
            ),

            const SizedBox(height: 18),

            // NAME -------------------------------------------------------------
            const Text("Name", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            _roundedTextField(),

            const SizedBox(height: 18),

            // EXPIRY DATE ------------------------------------------------------
            const Text("Expiry date", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(child: _roundedTextField(hint: "DD")),
                const SizedBox(width: 10),
                Expanded(child: _roundedTextField(hint: "MM")),
                const SizedBox(width: 10),
                Expanded(child: _roundedTextField(hint: "YYYY")),
              ],
            ),

            const SizedBox(height: 18),

            // CAMERA / MIC / CALENDAR -----------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconCircle(Icons.camera_alt, () {}),
                _iconCircle(Icons.mic, () => _showMicPopup(context)),
                _iconCircle(Icons.calendar_today, () {}),
              ],
            ),

            const SizedBox(height: 25),

            // AMOUNT -----------------------------------------------------------
            const Text("Amount", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            _buildDropdown(
              value: selectedAmount,
              hint: "Select Amount Unit",
              items: amountUnits,
              onChanged: (v) => setState(() => selectedAmount = v),
            ),

            const SizedBox(height: 30),

            // DONE BUTTON ------------------------------------------------------
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET HELPERS
  // ---------------------------------------------------------------------------

  Widget _roundedTextField({String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.green, size: 30),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MIC POPUP DIALOG
  // ---------------------------------------------------------------------------

  void _showMicPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Text(
                        "Speak the expiry date clearly in this order",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "📅 Day → Month → Year",
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Start"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
