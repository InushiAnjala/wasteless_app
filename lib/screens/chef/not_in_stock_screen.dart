import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chef_home_screen.dart';
import 'chef_food_screen.dart';
import 'ai_food_recipes_screen.dart';
import '../../widgets/back_button.dart';

class NotInStockScreen extends StatefulWidget {
  final bool adminMode;
  final void Function(int index)? onTabSelected;
  const NotInStockScreen({super.key, this.adminMode = false, this.onTabSelected});

  @override
  State<NotInStockScreen> createState() => _NotInStockScreenState();
}

class _NotInStockScreenState extends State<NotInStockScreen> {
  static const int _maxRows = 25;
  static List<String> _draftNames = [];
  static List<String> _draftAmounts = [];
  bool _clearDraftOnDispose = false;

  // Controllers for dynamic rows
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> amountControllers = [];

  @override
  void initState() {
    super.initState();
    // Start with draft rows if present, otherwise three rows.
    final initialCount = _draftNames.isNotEmpty ? _draftNames.length : 3;
    for (int i = 0; i < initialCount; i++) {
      final name = i < _draftNames.length ? _draftNames[i] : '';
      final amount = i < _draftAmounts.length ? _draftAmounts[i] : '';
      _addRow(initial: true, name: name, amount: amount);
    }
  }

  @override
  void dispose() {
    if (_clearDraftOnDispose) {
      _draftNames = [];
      _draftAmounts = [];
    } else {
      _draftNames = [for (final c in nameControllers) c.text];
      _draftAmounts = [for (final c in amountControllers) c.text];
    }
    for (final c in nameControllers) {
      c.dispose();
    }
    for (final c in amountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.adminMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: WasteLessBackButton(onPressed: () => Navigator.pop(context)),
                      ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25C06D),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.remove_shopping_cart,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Not in stock",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Track what needs replenishing and quantities.",
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

              const SizedBox(height: 18),

              // Entry card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
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
                  children: [
                    ..._rowList(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: nameControllers.length >= _maxRows
                            ? null
                            : () => _addRow(),
                        icon: const Icon(Icons.add),
                        label: Text(
                          nameControllers.length >= _maxRows
                              ? 'Maximum items reached'
                              : 'Add another item',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25C06D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _submitNeeds,
                        child: const Text(
                          'Send to Kitchen Needs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _rowList() {
    final widgets = <Widget>[];
    for (int i = 0; i < nameControllers.length; i++) {
      if (i > 0) {
        widgets.add(const Divider(height: 22, color: Color(0xFFE6EAE7)));
      }
      widgets.add(_editableRow(i + 1, i));
    }
    return widgets;
  }

  // ROW UI — Name + Amount
  Widget _editableRow(int number, int index) {
    return Row(
      children: [
        Text(
          "$number.",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 20),

        // Name Field
        Expanded(
          flex: 2,
          child: TextField(
            controller: nameControllers[index],
            decoration: const InputDecoration(
              hintText: "Item name",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            onChanged: (_) => _clearDraftOnDispose = false,
          ),
        ),

        const SizedBox(width: 10),

        const Text("|", style: TextStyle(fontSize: 18, color: Colors.black45)),

        const SizedBox(width: 10),

        // Amount Field
        Expanded(
          flex: 3,
          child: TextField(
            controller: amountControllers[index],
            decoration: const InputDecoration(
              hintText: "Amount needed",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            keyboardType: TextInputType.number,
            onChanged: (_) => _clearDraftOnDispose = false,
          ),
        ),
      ],
    );
  }

  void _addRow({bool initial = false, String name = '', String amount = ''}) {
    if (!initial && nameControllers.length >= _maxRows) return;
    void add() {
      nameControllers.add(TextEditingController(text: name));
      amountControllers.add(TextEditingController(text: amount));
    }

    if (initial) {
      add();
    } else {
      setState(add);
    }
  }

  Future<void> _submitNeeds() async {
    final entries = <Map<String, String>>[];

    for (int i = 0; i < nameControllers.length; i++) {
      final name = nameControllers[i].text.trim();
      final amount = amountControllers[i].text.trim();
      if (name.isEmpty || amount.isEmpty) continue;
      entries.add({'name': name, 'amount': amount});
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to send')),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final needs = FirebaseFirestore.instance.collection('kitchen_needs');

      for (final item in entries) {
        final doc = needs.doc();
        batch.set(doc, {
          'name': item['name'],
          'amount': item['amount'],
          'status': 'pending',
          'createdAt': DateTime.now(),
        });
      }

      await batch.commit();

      for (final c in nameControllers) {
        c.clear();
      }
      for (final c in amountControllers) {
        c.clear();
      }

      _draftNames = [];
      _draftAmounts = [];
      _clearDraftOnDispose = true;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sent to Kitchen Needs')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send items')));
    }
  }
}

