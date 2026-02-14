import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'main_screen.dart';
import '../../constants/text_styles.dart';

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

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  String? selectedSection;
  String? selectedUnit;
  DateTime? selectedExpiryDate;

  final List<String> sectionList = ["Veges", "Fruits", "Meat", "Others"];
  final List<String> unitList = ["Kg", "g", "L", "ml", "Unit"];

  int _currentIndex = 0;

  bool get isEdit => widget.foodId != null;

  @override
  void initState() {
    super.initState();
    _currentIndex = isEdit ? 1 : 0;

    if (isEdit) {
      final data = widget.foodData!;
      nameController.text = data["name"];
      amountController.text = data["amount"].toString();
      selectedSection = data["section"];
      selectedUnit = data["unit"];
      selectedExpiryDate = (data["expiryDate"] as Timestamp).toDate();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    _textRecognizer.close();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required DateTime firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  DateTime? _parseDateFromText(String text) {
    final match = RegExp(
      r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
    ).firstMatch(text);
    if (match == null) return null;
    final day = int.tryParse(match.group(1) ?? "");
    final month = int.tryParse(match.group(2) ?? "");
    var year = int.tryParse(match.group(3) ?? "");
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    return DateTime(year, month, day);
  }

  Future<void> _scanTextFromCamera() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final lines = recognizedText.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No text detected")));
        return;
      }

      DateTime? parsedExpDate;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lower = line.toLowerCase();

        if (lower.contains("exp") || lower.contains("expiry")) {
          parsedExpDate =
              _parseDateFromText(line) ??
              (i + 1 < lines.length ? _parseDateFromText(lines[i + 1]) : null);
        }
      }

      if (!mounted) return;
      bool updated = false;
      setState(() {
        if (parsedExpDate != null) {
          selectedExpiryDate = parsedExpDate;
          updated = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated
                ? "Expiry date captured."
                : "Scan captured, but no expiry date was found.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Scan failed: $e")));
    }
  }

  Future<void> _saveFood() async {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedUnit == null ||
        selectedSection == null ||
        selectedExpiryDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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
      await FirebaseFirestore.instance.collection("foods").add({
        ...foodData,
        "createdAt": Timestamp.now(),
      });
    }

    Navigator.pop(context);
  }

  void _navigateToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FFF6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF3FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              offset: const Offset(0, 10),
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
                                Icons.restaurant_menu,
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
                                    isEdit ? "Edit Food" : "Add Food",
                                    style: AppTextStyles.heading.copyWith(
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Log items faster with scan or manual entry.",
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

                      const Text(
                        "Section",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _dropdown(
                        value: selectedSection,
                        hint: "Select Section",
                        items: sectionList,
                        onChanged: (v) => setState(() => selectedSection = v),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _input(controller: nameController, hint: "Food name"),

                      const SizedBox(height: 18),

                      const Text(
                        "Expiry date",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(
                                current: selectedExpiryDate,
                                firstDate: DateTime.now(),
                                onPicked: (date) => selectedExpiryDate = date,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.1),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: Color(0xFF1E9E5A),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedExpiryDate == null
                                            ? "Select expiry date"
                                            : "${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _icon(Icons.camera_alt, _scanTextFromCamera),
                          const SizedBox(width: 8),
                          _icon(Icons.mic, () {}),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Amount",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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
                              onChanged: (v) =>
                                  setState(() => selectedUnit = v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: ElevatedButton(
                          onPressed: _saveFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25C06D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 44,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            shadowColor: Colors.green.withOpacity(0.25),
                            elevation: 6,
                          ),
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Food List',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Kitchen'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E9E5A), size: 24),
      ),
    );
  }
}
