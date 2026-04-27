import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages all on-device scheduled push notifications for food expiry alerts.
///
/// Two notifications are scheduled per food item:
///   1. Threshold alert  – fires at 8 AM, N days before expiry (per category pref)
///                         If that 8 AM is already past today, fires in 5 seconds.
///   2. Expiry-day alert – fires at 8 AM on the actual expiry date.
///                         If item expires today and 8 AM already passed, fires in 5 seconds.
///
/// Call [initialize] once at app start, then [scheduleAllNotifications]
/// whenever the food list or preferences might have changed.
///
/// Call [testNotificationNow] to fire real food-list notifications in 10 seconds
/// (useful for verifying the feature is working during development).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ──────────────────────────────────────────────────
  // INITIALISE
  // ──────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;

    // Load timezone data (bundled with the timezone package)
    tz_data.initializeTimeZones();

    // Set to Colombo (Sri Lanka)
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request iOS permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  // ──────────────────────────────────────────────────
  // SCHEDULE ALL (the real food list)
  // ──────────────────────────────────────────────────

  /// Reads all food items + notification preferences from Firestore,
  /// cancels every previously scheduled notification, then re-schedules
  /// fresh ones for every relevant item.
  ///
  /// KEY FIX: If the ideal fire time (8 AM) is already past today, we
  /// immediately schedule the notification for 5 seconds from now instead
  /// of silently skipping it.
  Future<void> scheduleAllNotifications() async {
    await initialize();

    // 1. Load notification preferences
    final Map<String, int> thresholds = await _loadThresholds();

    // 2. Cancel all old notifications so we start clean
    await _plugin.cancelAll();

    // 3. Load all food items
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // IDs: threshold alerts start at 2000, expiry-day at 3000
    // (reserves 1000–1999 for future use; test uses 1–99)
    int thresholdId = 2000;
    int expiryId = 3000;
    int staggerDelaySeconds = 5;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String name = (data['name'] as String?) ?? 'Food item';
      final String section = (data['section'] as String?) ?? 'Others';
      final Timestamp? expiryTs = data['expiryDate'] as Timestamp?;

      if (expiryTs == null) continue;

      final DateTime expiryDate = expiryTs.toDate();
      final DateTime expiryDay =
          DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

      // Skip items that already expired yesterday or earlier
      if (expiryDay.isBefore(today)) continue;

      // Also skip items with zero amount (already used up)
      final dynamic amount = data['amount'];
      double qty = 0;
      if (amount is num) qty = amount.toDouble();
      if (amount is String) qty = double.tryParse(amount) ?? 0;
      if (qty <= 0) continue;

      final int thresholdDays = thresholds[section] ?? 0;


      // ── Notification 1: Threshold alert ──────────────────────────
      if (thresholdDays > 0) {
        final DateTime thresholdDate =
            expiryDate.subtract(Duration(days: thresholdDays));
        final DateTime thresholdAt8am = DateTime(
          thresholdDate.year,
          thresholdDate.month,
          thresholdDate.day,
          8,
        );

        if (thresholdAt8am.isAfter(now)) {
          await _scheduleNotification(
            id: thresholdId++,
            title: '${_categoryEmoji(section)} $name is expiring soon!',
            body:
                'Expires in $thresholdDays days (${_fmtDate(expiryDate)}). Use it before it goes bad!',
            scheduledAt: thresholdAt8am,
          );
        } else if (thresholdAt8am.year == now.year &&
                   thresholdAt8am.month == now.month &&
                   thresholdAt8am.day == now.day) {
          // If it was supposed to fire today at 8 AM but we missed it, fire it staggered
          await _scheduleNotification(
            id: thresholdId++,
            title: '${_categoryEmoji(section)} $name is expiring soon!',
            body:
                'Expires in $thresholdDays days (${_fmtDate(expiryDate)}). Use it before it goes bad!',
            scheduledAt: now.add(Duration(seconds: staggerDelaySeconds)),
          );
          staggerDelaySeconds += 2; // Stagger next notification by 2s
        }
      }

      // ── Notification 2: Expiry-day alert ─────────────────────────
      final DateTime expiryAt8am = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
        8,
      );

      if (expiryAt8am.isAfter(now)) {
        await _scheduleNotification(
          id: expiryId++,
          title: '⚠️ $name expires TODAY!',
          body:
              'Your $section item "$name" expires today (${_fmtDate(expiryDate)}). Use or discard it now!',
          scheduledAt: expiryAt8am,
        );
      } else if (expiryAt8am.year == now.year &&
                 expiryAt8am.month == now.month &&
                 expiryAt8am.day == now.day) {
        // If it was supposed to fire today at 8 AM but we missed it, fire it staggered
        await _scheduleNotification(
          id: expiryId++,
          title: '⚠️ $name expires TODAY!',
          body:
              'Your $section item "$name" expires today (${_fmtDate(expiryDate)}). Use or discard it now!',
          scheduledAt: now.add(Duration(seconds: staggerDelaySeconds)),
        );
        staggerDelaySeconds += 2; // Stagger next notification by 2s
      }
    }
  }

  // ──────────────────────────────────────────────────
  // CANCEL ALL
  // ──────────────────────────────────────────────────
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ──────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'wasteless_expiry_channel',
      'Food Expiry Alerts',
      channelDescription:
          'Notifies you when food items are about to expire.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<Map<String, int>> _loadThresholds() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('notification_preferences')
          .get();

      if (!doc.exists || doc.data() == null) return {};

      final data = doc.data()!;
      final Map<String, int> result = {};

      for (final section in ['Veges', 'Fruits', 'Meat', 'Others']) {
        final raw = data[section];
        if (raw is Map<String, dynamic>) {
          final int value = (raw['value'] as num?)?.toInt() ?? 0;
          final String unit = (raw['unit'] as String?) ?? 'Days';
          result[section] = unit == 'Months' ? value * 30 : value;
        }
      }

      return result;
    } catch (_) {
      return {};
    }
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _categoryEmoji(String section) {
    switch (section) {
      case 'Veges':
        return '🥦';
      case 'Fruits':
        return '🍎';
      case 'Meat':
        return '🥩';
      default:
        return '🧺';
    }
  }
}
