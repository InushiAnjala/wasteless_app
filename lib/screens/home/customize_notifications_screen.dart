import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ...existing code...

class CustomizeNotificationsScreen extends StatefulWidget {
  const CustomizeNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<CustomizeNotificationsScreen> createState() =>
      _CustomizeNotificationsScreenState();
}

class _CustomizeNotificationsScreenState
    extends State<CustomizeNotificationsScreen> {
  // ---------------- CONTROLLERS ----------------
  final TextEditingController vegCtrl = TextEditingController();
  final TextEditingController fruitsCtrl = TextEditingController();
  final TextEditingController meatCtrl = TextEditingController();
  final TextEditingController othersCtrl = TextEditingController();

  // ---------------- DROPDOWN VALUES ----------------
  String vegUnit = "Days";
  String fruitUnit = "Days";
  String meatUnit = "Days";
  String otherUnit = "Days";

  // ---------------- LOAD SETTINGS ----------------
  Future<void> _loadSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection("app_settings")
        .doc("notification_preferences")
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      vegCtrl.text = data["Veges"]?["value"]?.toString() ?? "";
      vegUnit = data["Veges"]?["unit"] ?? "Days";

      fruitsCtrl.text = data["Fruits"]?["value"]?.toString() ?? "";
      fruitUnit = data["Fruits"]?["unit"] ?? "Days";

      meatCtrl.text = data["Meat"]?["value"]?.toString() ?? "";
      meatUnit = data["Meat"]?["unit"] ?? "Days";

      othersCtrl.text = data["Others"]?["value"]?.toString() ?? "";
      otherUnit = data["Others"]?["unit"] ?? "Days";
    });
  }

  // ---------------- SAVE SETTINGS ----------------
  Future<void> _saveSettings() async {
    await FirebaseFirestore.instance
        .collection("app_settings")
        .doc("notification_preferences")
        .set({
          "Veges": {"value": int.tryParse(vegCtrl.text) ?? 0, "unit": vegUnit},
          "Fruits": {
            "value": int.tryParse(fruitsCtrl.text) ?? 0,
            "unit": fruitUnit,
          },
          "Meat": {"value": int.tryParse(meatCtrl.text) ?? 0, "unit": meatUnit},
          "Others": {
            "value": int.tryParse(othersCtrl.text) ?? 0,
            "unit": otherUnit,
          },
          "updatedAt": Timestamp.now(),
        });
  }

  // ---------------- UI ----------------
  Widget buildSection({
    required String title,
    required TextEditingController controller,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Number",
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "Days", child: Text("Days")),
                    DropdownMenuItem(value: "Months", child: Text("Months")),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 45),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA8F5A3), Color(0xFFE7FFE9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ---------------- BACK + TITLE ----------------
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _saveSettings();
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Customize Notifications",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    buildSection(
                      title: "Veges",
                      controller: vegCtrl,
                      value: vegUnit,
                      onChanged: (v) => setState(() => vegUnit = v!),
                    ),

                    const SizedBox(height: 22),

                    buildSection(
                      title: "Fruits",
                      controller: fruitsCtrl,
                      value: fruitUnit,
                      onChanged: (v) => setState(() => fruitUnit = v!),
                    ),

                    const SizedBox(height: 22),

                    buildSection(
                      title: "Meat",
                      controller: meatCtrl,
                      value: meatUnit,
                      onChanged: (v) => setState(() => meatUnit = v!),
                    ),

                    const SizedBox(height: 22),

                    buildSection(
                      title: "Others",
                      controller: othersCtrl,
                      value: otherUnit,
                      onChanged: (v) => setState(() => otherUnit = v!),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () async {
                        await _saveSettings();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings saved!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
