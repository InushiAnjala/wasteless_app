import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChefFoodScreen extends StatefulWidget {
  final bool adminMode;
  const ChefFoodScreen({super.key, this.adminMode = false});

  @override
  State<ChefFoodScreen> createState() => _ChefFoodScreenState();
}

class _ChefFoodScreenState extends State<ChefFoodScreen> {
  String searchText = "";
  String selectedCategory = "Veges";
  final List<String> categories = ["Veges", "Meat", "Fruits", "Others"];

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
                _header(),
                const SizedBox(height: 18),
                _searchBar(),
                const SizedBox(height: 16),
                _categoryChips(),
                const SizedBox(height: 16),
                Expanded(child: _foodList()),
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
        children: [
          const Icon(Icons.kitchen, color: Color(0xFF1E9E5A), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Food List",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  "Browse by category, search, and mark needs.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
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
            child: const Icon(Icons.list_alt, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search food",
          border: InputBorder.none,
        ),
        onChanged: (value) => setState(() => searchText = value.toLowerCase()),
      ),
    );
  }

  Widget _categoryChips() {
    return Row(
      children: categories
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _categoryButton(c),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _categoryButton(String text) {
    final bool isSelected = selectedCategory == text;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _foodList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("foods")
          .where("section", isEqualTo: selectedCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final msg = snapshot.error?.toString() ?? "Unable to load foods";
          return Center(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No food items found",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs.where((doc) {
          final map = doc.data() as Map<String, dynamic>?;
          final name = (map?["name"] ?? "").toString().toLowerCase();
          return name.contains(searchText);
        }).toList();

        // Filter out expired items (shown elsewhere), zero stock, and sort by expiry
        final now = DateTime.now();
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final expiryField = data?["expiryDate"];
          DateTime? expiry;
          if (expiryField is Timestamp) expiry = expiryField.toDate();
          if (expiryField is DateTime) expiry = expiryField;
          if (expiry != null) {
            final today = DateTime(now.year, now.month, now.day);
            if (expiry.isBefore(today)) return false;
          }

          final amount = _parseAmount(data?["amount"]);
          return amount > 0;
        }).toList();

        filtered.sort((a, b) {
          DateTime? ea;
          DateTime? eb;
          final da = a.data() as Map<String, dynamic>?;
          final db = b.data() as Map<String, dynamic>?;
          final ra = da?["expiryDate"];
          final rb = db?["expiryDate"];
          if (ra is Timestamp) ea = ra.toDate();
          if (ra is DateTime) ea = ra;
          if (rb is Timestamp) eb = rb.toDate();
          if (rb is DateTime) eb = rb;
          if (ea == null && eb == null) return 0;
          if (ea == null) return 1;
          if (eb == null) return -1;
          return ea.compareTo(eb);
        });

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "No matches for your search",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>?;

            final String name = (data?["name"] ?? "Unnamed").toString();
            final dynamic amountField = data?["amount"];
            final String unit = (data?["unit"] ?? "").toString();
            final String amountLabel = _formatAmount(amountField, unit);
            final String category = (data?["section"] ?? "").toString();

            final dynamic expiryField = data?["expiryDate"];
            DateTime? expiry;
            if (expiryField is Timestamp) {
              expiry = expiryField.toDate();
            } else if (expiryField is DateTime) {
              expiry = expiryField;
            }

            int daysLeft;
            String expiryText;
            if (expiry == null) {
              daysLeft = 9999;
              expiryText = "No expiry set";
            } else {
              daysLeft = expiry.difference(DateTime.now()).inDays;
              if (daysLeft == 0) {
                expiryText = "Expires today";
              } else if (daysLeft == 1) {
                expiryText = "Expires tomorrow";
              } else if (daysLeft < 0) {
                expiryText = "Expired";
              } else {
                expiryText = "Expires in $daysLeft days";
              }
            }

            return _foodCard(
              name: name,
              amount: amountLabel,
              category: category,
              expiryLabel: expiryText,
              daysLeft: daysLeft,
              onNeed: () => _showNeedDialog(name, doc.id, unit),
            );
          },
        );
      },
    );
  }

  Widget _foodCard({
    required String name,
    required String amount,
    required String category,
    required String expiryLabel,
    required int daysLeft,
    required VoidCallback onNeed,
  }) {
    final Color badgeColor;
    final Color badgeText;
    if (daysLeft < 0) {
      badgeColor = const Color(0xFFFFE5E5);
      badgeText = const Color(0xFFD64242);
    } else if (daysLeft <= 2) {
      badgeColor = const Color(0xFFFFF4E3);
      badgeText = const Color(0xFFCC7A00);
    } else {
      badgeColor = const Color(0xFFE7F8EE);
      badgeText = const Color(0xFF1E9E5A);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE7F1EA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.restaurant_rounded, color: badgeText, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      expiryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Need button placeholder (keeps UI parity with manager view)
          GestureDetector(
            onTap: onNeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF25C06D),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                "Need",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNeedDialog(String itemName, String foodId, String unit) {
    final controller = TextEditingController();

    showDialog(
      context: context,
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
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
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
                    gradient: LinearGradient(
                      colors: [Color(0xFF0BA360), Color(0xFF3CBA92)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need for $itemName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log a quick request so the kitchen can stock up.',
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Amount needed',
                      hintText: 'e.g., 5 $unit',
                      filled: true,
                      fillColor: const Color(0xFFF7F9FB),
                      prefixIcon: const Icon(
                        Icons.scale,
                        color: Color(0xFF25C06D),
                      ),
                      labelStyle: const TextStyle(color: Color(0xFF5B6675)),
                      hintStyle: const TextStyle(color: Color(0xFF9AA7B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF25C06D),
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: Color(0xFFE0E6ED)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF5B6675),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: const Color(0xFF25C06D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final value = controller.text.trim();
                            Navigator.pop(context);
                            late final _NeedRequest request;
                            try {
                              request = _parseNeedRequest(value, unit);
                            } on FormatException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                              return;
                            }
                            _submitNeed(
                              itemName: itemName,
                              request: request,
                              foodId: foodId,
                              unit: unit,
                            );
                          },
                          child: const Text(
                            'Save need',
                            style: TextStyle(
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
        );
      },
    );
  }

  Future<void> _submitNeed({
    required String itemName,
    required _NeedRequest request,
    required String foodId,
    required String unit,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final needsRef = firestore.collection('kitchen_needs').doc();
    final foodRef = firestore.collection('foods').doc(foodId);

    try {
      await firestore.runTransaction((transaction) async {
        final foodSnap = await transaction.get(foodRef);
        if (!foodSnap.exists) {
          throw Exception('Food item no longer exists');
        }

        final foodData = foodSnap.data();
        final currentAmount = _parseAmount(foodData?['amount']);
        if (request.stockAmount > currentAmount) {
          throw Exception(
            'Only ${_formatNumber(currentAmount)} $unit available. '
            'You requested ${request.displayLabel}. Please request less.',
          );
        }
        final newAmount = (currentAmount - request.stockAmount).clamp(
          0,
          double.infinity,
        );

        transaction.update(foodRef, {'amount': newAmount});
        transaction.set(needsRef, {
          'name': itemName,
          'amount': request.displayLabel,
          'createdAt': DateTime.now(),
          // Mark as requested so it appears in the upper section (not the
          // pending/not-in-stock list) on the manager reports page.
          'status': 'requested',
        });
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requested ${request.displayLabel} of $itemName'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final cleaned = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
      final msg = cleaned.trim().isNotEmpty
          ? cleaned
          : 'Failed to save request. Please try again.';
      _showErrorDialog(msg);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Color(0xFFD64242)),
              SizedBox(width: 8),
              Text('Request blocked'),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  _NeedRequest _parseNeedRequest(String input, String stockUnit) {
    final match = RegExp(
      r'^\s*([0-9]+(?:[\.,][0-9]+)?)\s*([A-Za-z]+)?\s*$',
    ).firstMatch(input);
    if (match == null) {
      throw const FormatException('Enter an amount like 5 Kg or 500 g');
    }

    final numeric = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (numeric == null || numeric <= 0) {
      throw const FormatException('Enter an amount greater than 0');
    }

    final typedUnit = match.group(2)?.trim();
    if (typedUnit == null || typedUnit.isEmpty) {
      return _NeedRequest(
        stockAmount: numeric,
        displayLabel: '${_formatNumber(numeric)} ${stockUnit.trim()}'.trim(),
      );
    }

    final requestedKey = _normalizeUnit(typedUnit);
    final stockKey = _normalizeUnit(stockUnit);
    final requestedFamily = _unitFamily(requestedKey);
    final stockFamily = _unitFamily(stockKey);

    if (requestedFamily == null) {
      throw const FormatException('Use a unit like Kg, g, L, ml, or Unit');
    }

    if (stockFamily == null || requestedFamily != stockFamily) {
      final hintUnit = stockUnit.trim().isEmpty
          ? 'this item'
          : stockUnit.trim();
      throw FormatException('Use a matching unit for $hintUnit');
    }

    final stockAmount =
        numeric * _unitBaseFactor(requestedKey) / _unitBaseFactor(stockKey);

    return _NeedRequest(
      stockAmount: stockAmount,
      displayLabel:
          '${_formatNumber(numeric)} ${_unitDisplayLabel(requestedKey)}'.trim(),
    );
  }

  String _normalizeUnit(String unit) {
    final cleaned = unit.trim().toLowerCase().replaceAll('.', '');
    switch (cleaned) {
      case 'kg':
      case 'kgs':
      case 'kilogram':
      case 'kilograms':
      case 'kilo':
      case 'kilos':
        return 'kg';
      case 'g':
      case 'gram':
      case 'grams':
        return 'g';
      case 'l':
      case 'liter':
      case 'liters':
      case 'litre':
      case 'litres':
        return 'l';
      case 'ml':
      case 'milliliter':
      case 'milliliters':
      case 'millilitre':
      case 'millilitres':
        return 'ml';
      case 'unit':
      case 'units':
      case 'piece':
      case 'pieces':
      case 'pc':
      case 'pcs':
        return 'unit';
    }
    return cleaned;
  }

  String? _unitFamily(String unitKey) {
    switch (unitKey) {
      case 'kg':
      case 'g':
        return 'weight';
      case 'l':
      case 'ml':
        return 'volume';
      case 'unit':
        return 'count';
    }
    return null;
  }

  double _unitBaseFactor(String unitKey) {
    switch (unitKey) {
      case 'kg':
      case 'l':
        return 1000;
      case 'g':
      case 'ml':
      case 'unit':
      default:
        return 1;
    }
  }

  String _unitDisplayLabel(String unitKey) {
    switch (unitKey) {
      case 'kg':
        return 'Kg';
      case 'g':
        return 'g';
      case 'l':
        return 'L';
      case 'ml':
        return 'ml';
      case 'unit':
        return 'Unit';
    }
    return unitKey;
  }

  String _formatNumber(double value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value
              .toStringAsFixed(2)
              .replaceAll(RegExp(r'\.0+$'), '')
              .replaceAll(RegExp(r'0+$'), '');
  }

  String _formatAmount(dynamic value, String unit) {
    final numeric = _parseAmount(value);
    if (numeric > 0) {
      final display = numeric % 1 == 0
          ? numeric.toInt().toString()
          : numeric.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return 'Amount: $display ${unit.trim()}'.trim();
    }

    final raw = value?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      return 'Amount: $raw ${unit.trim()}'.trim();
    }
    return 'Amount: -';
  }
}

class _NeedRequest {
  const _NeedRequest({required this.stockAmount, required this.displayLabel});

  final double stockAmount;
  final String displayLabel;
}
