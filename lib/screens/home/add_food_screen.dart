import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart'; // For HapticFeedback

import 'main_screen.dart';
import '../../constants/text_styles.dart';
import '../../widgets/back_button.dart';
import '../../services/notification_service.dart';

class AddFoodScreen extends StatefulWidget {
  final String? foodId;
  final Map<String, dynamic>? foodData;
  final bool adminMode;

  const AddFoodScreen({super.key, this.foodId, this.foodData, this.adminMode = false});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = "";

  static final RegExp _expiryRegex = RegExp(
    r'(EXP|Expiry|EXPIRY|Best\s*Before|BBE|Use\s*By|EXD)?\s*[:\-]?\s*'
    r'(\b\d{1,2}[\/\-\.\s:]\d{1,2}[\/\-\.\s:]\d{2,4}\b' // 12/05/2026 or 12 : 05 : 26
    r'|\b\d{4}[\/\-\.\s:]\d{1,2}[\/\-\.\s:]\d{1,2}\b' // 2026-05-12
    r'|\b\d{1,2}[\/\-\.\s:][A-Za-z]{3,9}[\/\-\.\s:]\d{2,4}\b' // 12 Aug 2026
    r'|\b[A-Za-z]{3,9}[\/\-\.\s:]\d{1,2}[\/\-\.\s:]\d{2,4}\b' // Aug 12 2026
    r'|\b\d{1,2}[\/\-\.\s:]\d{4}\b)', // 05/2026 or 05:2026
    caseSensitive: false,
  );

  static const Map<String, int> _monthLookup = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

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
    _speech = stt.SpeechToText();
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
    _stopListening();
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

  int? _parseMonth(String part) {
    final numeric = int.tryParse(part);
    if (numeric != null) return numeric;
    final lower = part.toLowerCase();
    return _monthLookup[lower];
  }

  int? _parseYear(String part) {
    final parsed = int.tryParse(part);
    if (parsed == null) return null;
    if (parsed < 100) return parsed + 2000;
    return parsed;
  }

  DateTime? _buildDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12) return null;
    final candidate = DateTime(year, month, day);
    return (candidate.year == year &&
            candidate.month == month &&
            candidate.day == day)
        ? candidate
        : null;
  }

  DateTime? _parseExpiryString(String rawDate) {
    final cleaned = rawDate.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = cleaned
      .split(RegExp(r'[\/\-\.\s:]'))
      .where((p) => p.isNotEmpty)
      .toList();

    if (parts.length < 2 || parts.length > 3) return null;

    int? day;
    int? month;
    int? year;

    if (parts.length == 3) {
      // Try D-M-Y
      day = int.tryParse(parts[0]);
      month = _parseMonth(parts[1]);
      year = _parseYear(parts[2]);

      var candidate = _buildDate(year, month, day);
      if (candidate != null) return candidate;

      // Try M-D-Y
      month = _parseMonth(parts[0]);
      day = int.tryParse(parts[1]);
      year = _parseYear(parts[2]);
      candidate = _buildDate(year, month, day);
      if (candidate != null) return candidate;

      // Try Y-M-D
      year = _parseYear(parts[0]);
      month = _parseMonth(parts[1]);
      day = int.tryParse(parts[2]);
      candidate = _buildDate(year, month, day);
      if (candidate != null) return candidate;
    } else {
      // Month + Year (assume day 1)
      month = _parseMonth(parts[0]);
      year = _parseYear(parts[1]);
      return _buildDate(year, month, 1);
    }

    return null;
  }

  DateTime? _extractExpiryDate(String text) {
    final normalized = text.replaceAll('\n', ' ');

    for (final match in _expiryRegex.allMatches(normalized)) {
      // If the matched date has a preceding MFD, skip it.
      // But because the regex doesn't capture MFD, we can check the text 
      // immediately before the match index.
      int startIndex = match.start;
      int checkStart = (startIndex - 10) < 0 ? 0 : startIndex - 10;
      String precedingText = normalized.substring(checkStart, startIndex).toUpperCase();
      
      if (precedingText.contains('MFD') || precedingText.contains('MANUFACTURED')) {
        continue; // Skip this date
      }

      final rawDate = match.group(2);
      if (rawDate == null) continue;
      final parsed = _parseExpiryString(rawDate);
      if (parsed != null) return parsed;
    }
    return null;
  }

  // ---------------- VOICE CAPTURE LOGIC ----------------
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (val) => setState(() => _isListening = false),
    );

    if (available) {
      setState(() => _isListening = true);
      HapticFeedback.heavyImpact();

      // Show a snackbar or small overlay telling them we are listening
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Listening... Speak your expiry date (Day Month Year)"),
          duration: Duration(seconds: 5),
        ),
      );

      await _speech.listen(
        onResult: (val) {
          setState(() {
            _lastWords = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _processVoiceInput(_lastWords);
            }
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Speech recognition not available.")),
        );
      }
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _processVoiceInput(String text) {
    if (text.isEmpty) return;

    // Clean text: "12th of August 2026" -> "12 August 2026"
    String cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'\b(of|the|at|on|in)\b'), '')
        .replaceAll(RegExp(r'(st|nd|rd|th)\b'), '')
        .trim();

    final parsed = _parseExpiryString(cleaned);

    if (parsed != null) {
      setState(() => selectedExpiryDate = parsed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Captured date: ${parsed.day}/${parsed.month}/${parsed.year}"),
          backgroundColor: const Color(0xFF1E9E5A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Couldn't understand '$text'. Try '12 August 2026'"),
          action: SnackBarAction(label: "Retry", onPressed: _startListening),
        ),
      );
    }
  }

  Future<void> _scanTextFromCamera() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final parsedExpDate = _extractExpiryDate(recognizedText.text);

      if (!mounted) return;

      if (parsedExpDate != null) {
        setState(() => selectedExpiryDate = parsedExpDate);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Expiry date captured.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No expiry date detected. Try again.")),
        );
      }
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

    if (!mounted) return;
    // Reschedule notifications so new/edited item is included immediately
    NotificationService.instance.scheduleAllNotifications();
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
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.16),
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
                                    color: Colors.green.withValues(alpha: 0.2),
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
                                      color: Colors.green.withValues(alpha: 0.1),
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
                          _icon(Icons.mic, _showVoicePrompt),
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
                            shadowColor: Colors.green.withValues(alpha: 0.25),
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

  void _showVoicePrompt() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFF17D7D)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Capture expiry by voice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Speak clearly and follow the date order below to avoid mistakes.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        splashRadius: 18,
                        onPressed: () {
                          Navigator.pop(context);
                          _showVoicePreferenceDialog();
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F0F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEED3D3)),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFFE53935),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Say it as: Day  →  Month  →  Year',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _VoiceChip(label: 'Example: 12 August 2026'),
                          _VoiceChip(label: 'Keep background quiet'),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      shadowColor: Colors.red.withValues(alpha: 0.26),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _startListening();
                    },
                    child: const Text(
                      'Start listening',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVoicePreferenceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 28,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E9E5A),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Voice tips visibility',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        splashRadius: 18,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Choose how often you want to see the voice instructions before recording.',
                        style: TextStyle(
                          color: Color(0xFF4D5561),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 14),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    children: [
                      _voicePrefButton('Show every time'),
                      const SizedBox(height: 10),
                      _voicePrefButton("Don't show again"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _voicePrefButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFB72827), width: 1),
          ),
          elevation: 2,
        ),
        onPressed: () {
          Navigator.pop(context);
          _startListening();
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
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
            color: Colors.green.withValues(alpha: 0.08),
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
              color: Colors.green.withValues(alpha: 0.12),
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

class _VoiceChip extends StatelessWidget {
  final String label;

  const _VoiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FFF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCF2E5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2F4236),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
