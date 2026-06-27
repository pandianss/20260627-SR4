import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationSettings({
    this.enabled = true,
    this.hour = 20, // default 8:00 PM
    this.minute = 0,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> j) =>
      NotificationSettings(
        enabled: j['enabled'] as bool? ?? true,
        hour: (j['hour'] as num?)?.toInt() ?? 20,
        minute: (j['minute'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };
}

/// Schedules a real, repeating daily local notification reminding the learner to
/// study. Uses a high-importance (heads-up) notification; settings persist
/// across launches. [init] must be called once at startup — until then the
/// service only tracks settings in memory (which keeps it usable in tests).
class NotificationService {
  static const _prefsKey = 'notif_settings_v1';
  static const _reminderId = 1001;
  static const _channelId = 'daily_study_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  NotificationSettings _settings = const NotificationSettings();
  int? _lastDueCount;

  NotificationSettings get settings => _settings;

  /// Initialise the plugin + timezone db, load persisted settings, and schedule
  /// the reminder. Failures are swallowed so a notification problem never blocks
  /// app startup.
  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        debugPrint('Timezone resolve failed, using default: $e');
      }

      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: initSettings);

      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_prefsKey);
        if (raw != null) {
          _settings = NotificationSettings.fromJson(
              jsonDecode(raw) as Map<String, dynamic>);
        }
      } catch (_) {}

      _ready = true;
      await requestPermission();
      await _reschedule();
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  /// Ask the OS for notification permission (Android 13+ / iOS). Returns whether
  /// it's granted.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          true;
    } catch (e) {
      debugPrint('requestPermission failed: $e');
      return false;
    }
  }

  Future<void> updateSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    _settings =
        NotificationSettings(enabled: enabled, hour: hour, minute: minute);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_settings.toJson()));
    } catch (_) {}
    if (_ready) {
      try {
        if (enabled) await requestPermission();
        await _reschedule();
      } catch (e) {
        debugPrint('Reschedule failed: $e');
      }
    }
  }

  /// Reschedule the study reminder with a dynamic due count.
  Future<void> rescheduleWithDueCount(int dueCount) async {
    _lastDueCount = dueCount;
    if (_ready) {
      try {
        await _reschedule();
      } catch (e) {
        debugPrint('rescheduleWithDueCount failed: $e');
      }
    }
  }

  Future<void> _reschedule() async {
    await _plugin.cancel(id: _reminderId);
    if (!_settings.enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, _settings.hour, _settings.minute);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Study reminders',
        channelDescription:
            'Daily reminder to study with SuperRecall Banker.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final due = _lastDueCount ?? 0;
    final String title;
    final String body;

    if (due > 0) {
      title = 'Time for your 5 minutes 📚';
      body = '$due review${due == 1 ? '' : 's'} due — 3 min';
    } else {
      title = 'Ready to study? 📚';
      body = 'Your spaced reviews are waiting — keep your streak alive.';
    }

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  /// Test/debug helper — returns the message that would fire for [dueCount].
  String? simulateNotificationTrigger(int dueCount) {
    if (!_settings.enabled) {
      debugPrint('Reminder not scheduled: notifications disabled.');
      return null;
    }
    if (dueCount <= 0) {
      debugPrint('Reminder not scheduled: no reviews due.');
      return null;
    }
    final timeStr =
        '${_settings.hour.toString().padLeft(2, '0')}:${_settings.minute.toString().padLeft(2, '0')}';
    final msg = '$dueCount review${dueCount == 1 ? '' : 's'} due — 3 min';
    debugPrint('Notification scheduled for $timeStr: "$msg"');
    return msg;
  }
}
