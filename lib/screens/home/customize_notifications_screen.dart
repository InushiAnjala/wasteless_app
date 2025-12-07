import 'package:flutter/material.dart';

class CustomizeNotificationsScreen extends StatefulWidget {
  const CustomizeNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<CustomizeNotificationsScreen> createState() =>
      _CustomizeNotificationsScreenState();
}

class _CustomizeNotificationsScreenState
    extends State<CustomizeNotificationsScreen> {
  // Text controllers
  final TextEditingController vegCtrl = TextEditingController();
  final TextEditingController fruitsCtrl = TextEditingController();
  final TextEditingController meatCtrl = TextEditingController();
  final TextEditingController othersCtrl = TextEditingController();

  // Dropdown values
  String vegUnit = "Days";
  String fruitUnit = "Days";
  String meatUnit = "Days";
  String otherUnit = "Days";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              const Text(
                "Customize\nNotifications",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // CLEAN REUSABLE SECTION CARD
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
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Number field
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
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
              ),

              const SizedBox(width: 15),

              // Dropdown
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
      ),
    );
  }
}
