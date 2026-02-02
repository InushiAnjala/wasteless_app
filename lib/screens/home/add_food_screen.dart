import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class AddFoodScreen extends StatefulWidget {
  final String? foodId;
  final Map<String, dynamic>? foodData;

  const AddFoodScreen({super.key, this.foodId, this.foodData});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String? selectedSection;
  String? selectedUnit;
  DateTime? selectedExpiryDate;

  final List<String> sectionList = ["Veges", "Fruits", "Meat", "Others"];
  final List<String> unitList = ["Kg", "L", "Unit"];

  bool get isEdit => widget.foodId != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final data = widget.foodData!;
      nameController.text = data["name"];
      amountController.text = data["amount"].toString();
      selectedSection = data["section"];
      selectedUnit = data["unit"];
<<<<<<< HEAD
      selectedExpiryDate =
          (data["expiryDate"] as Timestamp).toDate();
=======
      selectedExpiryDate = (data["expiryDate"] as Timestamp).toDate();
>>>>>>> 0459bece8bdde4df634011f788a989042e99139c
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedExpiryDate = picked);
    }
  }

  Future<void> _saveFood() async {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedUnit == null ||
        selectedSection == null ||
        selectedExpiryDate == null) {
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
>>>>>>> 0459bece8bdde4df634011f788a989042e99139c
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final foodData = {
      "userId": uid,
      "name": nameController.text.trim(),
      "section": selectedSection,
      "amount": double.tryParse(amountController.text) ?? 0,
      "unit": selectedUnit,
      "expiryDate": Timestamp.fromDate(selectedExpiryDate!),
    };

    if (isEdit) {
      await FirebaseFirestore.instance
          .collection("foods")
          .doc(widget.foodId)
          .update(foodData);
    } else {
<<<<<<< HEAD
      await FirebaseFirestore.instance
          .collection("foods")
          .add({...foodData, "createdAt": Timestamp.now()});
=======
      await FirebaseFirestore.instance.collection("foods").add({
        ...foodData,
        "createdAt": Timestamp.now(),
      });
>>>>>>> 0459bece8bdde4df634011f788a989042e99139c
    }

    Navigator.pop(context);
  }

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
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          isEdit ? "Edit Food" : "Add Food",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Section"),
            const SizedBox(height: 6),
            _dropdown(
              value: selectedSection,
              hint: "Select Section",
              items: sectionList,
              onChanged: (v) => setState(() => selectedSection = v),
            ),

            const SizedBox(height: 18),

            const Text("Name"),
            const SizedBox(height: 6),
            _input(controller: nameController, hint: "Food name"),

            const SizedBox(height: 18),

            const Text("Expiry date"),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedExpiryDate == null
                            ? "Select expiry date"
                            : "${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _icon(Icons.camera_alt, () {}),
                const SizedBox(width: 8),
                _icon(Icons.mic, () {}),
                const SizedBox(width: 8),
                _icon(Icons.calendar_today, _pickDate),
              ],
            ),

            const SizedBox(height: 20),

            const Text("Amount"),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _input(
                    controller: amountController,
                    hint: "Amount",
                    keyboard: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown(
                    value: selectedUnit,
                    hint: "Unit",
                    items: unitList,
                    onChanged: (v) => setState(() => selectedUnit = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _saveFood,
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
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdown({
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

  Widget _icon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.green, size: 26),
      ),
    );
  }
}
