import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomizeNotificationsScreen extends StatefulWidget {
  const CustomizeNotificationsScreen({super.key});

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

  bool _isEditing = false;

  // ---------------- DROPDOWN VALUES ----------------
  String vegUnit = "Days";
  String fruitUnit = "Days";
  String meatUnit = "Days";
  String otherUnit = "Days";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

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

    if (!mounted) return;
    setState(() => _isEditing = false);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA0F1B5), Color(0xFFEFFAF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card with back button and context
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7EA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customize Notifications",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Pick how early you want alerts for each category.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                buildSection(
                  title: "Veges",
                  controller: vegCtrl,
                  value: vegUnit,
                  onChanged: (v) => setState(() => vegUnit = v!),
                ),

                const SizedBox(height: 18),

                buildSection(
                  title: "Fruits",
                  controller: fruitsCtrl,
                  value: fruitUnit,
                  onChanged: (v) => setState(() => fruitUnit = v!),
                ),

                const SizedBox(height: 18),

                buildSection(
                  title: "Meat",
                  controller: meatCtrl,
                  value: meatUnit,
                  onChanged: (v) => setState(() => meatUnit = v!),
                ),

                const SizedBox(height: 18),

                buildSection(
                  title: "Others",
                  controller: othersCtrl,
                  value: otherUnit,
                  onChanged: (v) => setState(() => otherUnit = v!),
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF25C06D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    ElevatedButton(
                      onPressed: _isEditing
                          ? () async {
                              await _saveSettings();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Settings saved!'),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _isEditing
                            ? const Color(0xFF1E9E5A)
                            : const Color(0xFFB9E0C8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // REUSABLE INPUT + DROPDOWN CARD
  // -------------------------------------------------------------------
  Widget buildSection({
    required String title,
    required TextEditingController controller,
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5F4EA)),
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
                  Icons.timer,
                  size: 18,
                  color: Color(0xFF1E9E5A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: controller,
                    readOnly: !_isEditing,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: _isEditing
                          ? Colors.white
                          : const Color(0xFFF7FBF8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEditing
                              ? const Color(0xFF7CD1A9)
                              : const Color(0xFFE0EDE5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF25C06D),
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Number",
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isEditing
                          ? const Color(0xFF7CD1A9)
                          : const Color(0xFFE0EDE5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _isEditing ? Colors.white : const Color(0xFFF7FBF8),
                  ),
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _isEditing
                          ? const Color(0xFF1E9E5A)
                          : Colors.black45,
                    ),
                    items: const [
                      DropdownMenuItem(value: "Days", child: Text("Days")),
                      DropdownMenuItem(value: "Months", child: Text("Months")),
                    ],
                    onChanged: _isEditing ? onChanged : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
