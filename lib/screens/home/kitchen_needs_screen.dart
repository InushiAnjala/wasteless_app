import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/text_styles.dart';

class KitchenNeedsScreen extends StatefulWidget {
  const KitchenNeedsScreen({Key? key}) : super(key: key);

  @override
  State<KitchenNeedsScreen> createState() => _KitchenNeedsScreenState();
}

class _KitchenNeedsScreenState extends State<KitchenNeedsScreen> {
  final Set<String> _checkedPending = {};

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
                _header(),
                const SizedBox(height: 22),
                _needsList(width),
                const SizedBox(height: 26),
                _notInStockPanel(width),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: const Icon(Icons.kitchen, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kitchen Needs",
                  style: AppTextStyles.heading.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Quick check of items to buy or consume soon.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _needsList(double width) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kitchen_needs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Unable to load needs',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No requests yet',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        // Show only items that are not pending (e.g., done or other states)
        final docs = snapshot.data!.docs.where((doc) {
          final status = (doc['status'] ?? '').toString().toLowerCase().trim();
          return status.isNotEmpty && status != 'pending';
        }).toList();

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _clearAllNeeds(docs),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear all'),
              ),
            ),
            for (final doc in docs) ...[
              Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.redAccent),
                ),
                onDismissed: (_) async {
                  await doc.reference.delete();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${(doc['name'] ?? 'item')}'),
                    ),
                  );
                },
                child: _itemCard(
                  title: (doc['name'] ?? 'Unknown').toString(),
                  subtitle: (doc['status'] ?? 'pending').toString(),
                  amount: (doc['amount'] ?? '-').toString(),
                  value: (doc['status'] ?? 'pending') == 'done',
                  onChanged: (val) async {
                    final newStatus = val == true ? 'done' : 'pending';
                    await doc.reference.update({'status': newStatus});
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notInStockPanel(double width) {
    return Container(
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
          _stockRows(),
        ],
      ),
    );
  }

  Widget _stockRows() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kitchen_needs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            'No pending requests',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          );
        }

        final pendingDocs = snapshot.data!.docs.where((doc) {
          final status = (doc['status'] ?? '').toString().toLowerCase().trim();
          return status == 'pending';
        }).toList();

        if (pendingDocs.isEmpty) {
          return const Text(
            'No pending requests',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          );
        }

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _clearPendingNeeds(pendingDocs),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear all'),
              ),
            ),
            for (int i = 0; i < pendingDocs.length; i++) ...[
              _stockRow(i + 1, pendingDocs[i]),
              if (i != pendingDocs.length - 1)
                const Divider(height: 18, color: Color(0xFFE6EFE8)),
            ],
          ],
        );
      },
    );
  }

  Widget _stockRow(int index, DocumentSnapshot doc) {
    final name = (doc['name'] ?? 'Name').toString();
    final amount = (doc['amount'] ?? 'Amount').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$index. $name",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: _checkedPending.contains(doc.id),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (val) async {
                setState(() {
                  if (val == true) {
                    _checkedPending.add(doc.id);
                  } else {
                    _checkedPending.remove(doc.id);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNeeds(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cleared all kitchen needs')));
  }

  Future<void> _clearPendingNeeds(
    List<QueryDocumentSnapshot> pendingDocs,
  ) async {
    if (pendingDocs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in pendingDocs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleared pending not-in-stock items')),
    );
  }
}
