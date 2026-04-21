import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  final bool adminMode;
  const AlertScreen({Key? key, this.adminMode = false}) : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool _loadingPrefs = true;
  String? _prefsError;
  Map<String, _NotificationRule> _rules = {};
  bool _usingFallbackRules = false;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('notification_preferences')
          .get();

      if (!doc.exists || doc.data() == null) {
        setState(() {
          _loadingPrefs = false;
          _rules = {};
        });
        return;
      }

      final data = doc.data()!;

      setState(() {
        _rules = {
          'Veges': _NotificationRule.fromMap(data['Veges']),
          'Fruits': _NotificationRule.fromMap(data['Fruits']),
          'Meat': _NotificationRule.fromMap(data['Meat']),
          'Others': _NotificationRule.fromMap(data['Others']),
        };
        _usingFallbackRules = false;
        _loadingPrefs = false;
      });
    } catch (e) {
      setState(() {
        _prefsError = 'Unable to load notification preferences';
        _usingFallbackRules = true;
        _loadingPrefs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB7F5C7), Color(0xFFEFFDF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: const Text(
                        'Your Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _clearAll(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.done_all, color: Colors.green, size: 20),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (uid == null)
                const Text('Please sign in to see notifications'),
              if (_prefsError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _prefsError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_loadingPrefs)
                const Center(child: CircularProgressIndicator()),
              if (!_loadingPrefs && _usingFallbackRules)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Showing all items because notification preferences are missing.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!_loadingPrefs && uid != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: (() {
                        Query<Map<String, dynamic>> query = FirebaseFirestore
                            .instance
                            .collection('foods');
                        // Roles share notifications to ensure kitchen & store coordination
                        return query.snapshots();
                      })(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          final message = snapshot.error.toString();
                          final bool needsIndex =
                              message.contains('index') &&
                              message.contains('firestore');
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  needsIndex
                                      ? 'Firestore needs an index for this query. Tap the link shown in the console or Logs to create it, then reload.'
                                      : 'Could not load notifications: $message',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'If you see an index URL in the error output, open it to auto-create the index, wait for it to build, then reopen this page.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No food items found'),
                          );
                        }

                        final now = DateTime.now();
                        // Filter by user preferences and group by section for display.
                        final filtered = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final bool isRead =
                              (data['notifRead'] as bool?) ?? false;
                          if (isRead) return false; // hide already acknowledged
                          final String section =
                              (data['section'] as String?) ?? 'Others';
                          final rule = _ruleForSection(section);
                          if (rule.daysThreshold <= 0) {
                            return false;
                          }

                          final DateTime expiry =
                              (data['expiryDate'] as Timestamp).toDate();
                          final int daysUntil = expiry.difference(now).inDays;
                          return daysUntil <= rule.daysThreshold;
                        }).toList();

                        // Group items by section and sort each group by expiry.
                        final List<String> sectionOrder = [
                          'Veges',
                          'Fruits',
                          'Meat',
                          'Others',
                        ];
                        final Map<String, List<QueryDocumentSnapshot>> grouped =
                            {for (final s in sectionOrder) s: []};

                        for (final doc in filtered) {
                          final data = doc.data() as Map<String, dynamic>;
                          final String section =
                              (data['section'] as String?) ?? 'Others';
                          grouped[section]?.add(doc);
                        }

                        for (final entry in grouped.entries) {
                          entry.value.sort((a, b) {
                            final aExp =
                                ((a.data()
                                            as Map<
                                              String,
                                              dynamic
                                            >)['expiryDate']
                                        as Timestamp)
                                    .toDate();
                            final bExp =
                                ((b.data()
                                            as Map<
                                              String,
                                              dynamic
                                            >)['expiryDate']
                                        as Timestamp)
                                    .toDate();
                            return aExp.compareTo(bExp);
                          });
                        }

                        final nonEmptySections = sectionOrder
                            .where((s) => grouped[s]?.isNotEmpty == true)
                            .toList();

                        if (nonEmptySections.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nothing to notify right now based on your preferences.',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: nonEmptySections.length,
                          itemBuilder: (context, sectionIndex) {
                            final section = nonEmptySections[sectionIndex];
                            final items = grouped[section]!;

                            return Container(
                              margin: EdgeInsets.only(
                                bottom:
                                    sectionIndex == nonEmptySections.length - 1
                                    ? 0
                                    : 14,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _sectionDot(section),
                                      const SizedBox(width: 8),
                                      Text(
                                        section,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...items.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final DateTime expiry =
                                        (data['expiryDate'] as Timestamp)
                                            .toDate();
                                    final int daysUntil = expiry
                                        .difference(now)
                                        .inDays;
                                    final String message =
                                        _buildNotificationText(data, expiry);
                                    final String amountText =
                                        '${data['amount']} ${data['unit'] ?? ''}'
                                            .trim();
                                    final bool isRead =
                                        (data['notifRead'] as bool?) ?? false;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildNotificationCard(
                                        title: data['name'] ?? 'Item',
                                        subtitle: message,
                                        amountText: amountText,
                                        daysUntil: daysUntil,
                                        isRead: isRead,
                                        onMarkRead: () async {
                                          await _markAsRead(doc.id);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildNotificationText(Map<String, dynamic> data, DateTime expiry) {
    final String name = (data['name'] as String?) ?? 'Item';
    final dynamic amount = data['amount'];
    final String unit = (data['unit'] as String?) ?? '';

    final int daysUntil = expiry.difference(DateTime.now()).inDays;

    String expiryText;
    if (daysUntil < 0) {
      final int daysAgo = daysUntil.abs();
      expiryText = 'Expired $daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else if (daysUntil == 0) {
      expiryText = 'Expires today';
    } else if (daysUntil == 1) {
      expiryText = 'Expires tomorrow';
    } else {
      expiryText = 'Expires in $daysUntil days';
    }

    return '$name $expiryText, $amount $unit';
  }

  _NotificationRule _ruleForSection(String section) {
    // Use saved rule when available; otherwise fall back to a wide window so
    // items do not disappear unexpectedly when preferences are missing.
    final rule = _rules[section];
    if (rule != null) return rule;
    _usingFallbackRules = true;
    return const _NotificationRule(value: 365, unit: 'Days');
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String amountText,
    required int daysUntil,
    required bool isRead,
    required Future<void> Function() onMarkRead,
  }) {
    final Color pillColor = _urgencyColor(daysUntil);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: pillColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active, color: pillColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pillColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _badgeText(daysUntil),
                        style: TextStyle(
                          color: pillColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isRead
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isRead ? Colors.grey : pillColor,
                      ),
                      onPressed: isRead ? null : () => onMarkRead(),
                      tooltip: 'Mark as read',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  amountText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDot(String section) {
    final color = _sectionColor(section);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _sectionColor(String section) {
    switch (section) {
      case 'Veges':
        return Colors.green.shade600;
      case 'Fruits':
        return Colors.orange.shade600;
      case 'Meat':
        return Colors.red.shade500;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  Color _urgencyColor(int daysUntil) {
    if (daysUntil < 0) return Colors.red.shade600;
    if (daysUntil <= 1) return Colors.orange.shade700;
    if (daysUntil <= 3) return Colors.amber.shade700;
    return Colors.green.shade700;
  }

  String _badgeText(int daysUntil) {
    if (daysUntil < 0) {
      final ago = daysUntil.abs();
      return '$ago day${ago == 1 ? '' : 's'} ago';
    }
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return '$daysUntil days';
  }

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance.collection('foods').doc(docId).set({
      'notifRead': true,
    }, SetOptions(merge: true));
  }

  Future<void> _clearAll() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear All Notifications?'),
          content: const Text('This will mark all currently visible alerts as read.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Clear All'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Fetch the same notifications that are currently being shown
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('foods');
      query = query.where('notifRead', isEqualTo: false);

      final snapshot = await query.get();
      final now = DateTime.now();
      final batch = FirebaseFirestore.instance.batch();

      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String section = (data['section'] as String?) ?? 'Others';
        final rule = _ruleForSection(section);
        if (rule.daysThreshold <= 0) continue;

        final DateTime expiry = (data['expiryDate'] as Timestamp).toDate();
        final int daysUntil = expiry.difference(now).inDays;

        if (daysUntil <= rule.daysThreshold) {
          batch.update(doc.reference, {'notifRead': true});
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleared $count notifications')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear notifications: $e')),
      );
    }
  }
}

class _NotificationRule {
  const _NotificationRule({required this.value, required this.unit});

  final int value;
  final String unit;

  int get daysThreshold => unit == 'Months' ? value * 30 : value;

  factory _NotificationRule.fromMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final int value = (raw['value'] as num?)?.toInt() ?? 0;
      final String unit = (raw['unit'] as String?) ?? 'Days';
      return _NotificationRule(value: value, unit: unit);
    }
    return const _NotificationRule(value: 0, unit: 'Days');
  }
}
