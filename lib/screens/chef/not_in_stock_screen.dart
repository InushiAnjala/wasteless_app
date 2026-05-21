import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotInStockScreen extends StatefulWidget {
  final bool adminMode;
  final void Function(int index)? onTabSelected;
  const NotInStockScreen({
    super.key,
    this.adminMode = false,
    this.onTabSelected,
  });

  @override
  State<NotInStockScreen> createState() => _NotInStockScreenState();
}

class _NotInStockScreenState extends State<NotInStockScreen> {
  static const int _maxRows = 25;

  // Controllers for dynamic rows
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> amountControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with 3 rows if empty
    if (nameControllers.isEmpty) {
      for (int i = 0; i < 3; i++) {
        _addRow(initial: true);
      }
    }
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25C06D),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.22),
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
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.12),
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
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            label: Text(
                              nameControllers.length >= _maxRows
                                  ? 'Maximum items reached'
                                  : 'Add another item',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF25C06D),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25C06D),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF25C06D),
          ),
        ),

        const SizedBox(width: 12),

        // Name Field
        Expanded(
          flex: 3,
          child: TextField(
            controller: nameControllers[index],
            decoration: const InputDecoration(
              hintText: "Item name",
              hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),

        const Text("|", style: TextStyle(fontSize: 16, color: Colors.black12)),

        const SizedBox(width: 8),

        // Amount Field
        Expanded(
          flex: 2,
          child: TextField(
            controller: amountControllers[index],
            decoration: const InputDecoration(
              hintText: "Qty/Amount",
              hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            keyboardType: TextInputType.text,
          ),
        ),

        if (nameControllers.length > 1)
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _removeRow(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  void _removeRow(int index) {
    setState(() {
      nameControllers[index].dispose();
      amountControllers[index].dispose();
      nameControllers.removeAt(index);
      amountControllers.removeAt(index);
    });
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
