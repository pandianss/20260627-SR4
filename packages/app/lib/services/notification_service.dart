import 'package:flutter/material.dart';

class NotificationSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationSettings({
    this.enabled = true,
    this.hour = 20, // default 8:00 PM
    this.minute = 0,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> j) => NotificationSettings(
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

class NotificationService {
  NotificationSettings _settings = const NotificationSettings();

  NotificationSettings get settings => _settings;

  void updateSettings({required bool enabled, required int hour, required int minute}) {
    _settings = NotificationSettings(enabled: enabled, hour: hour, minute: minute);
    debugPrint('Notification settings updated: enabled=$enabled, time=$hour:$minute');
  }

  String? simulateNotificationTrigger(int dueCount) {
    if (!_settings.enabled) {
      debugPrint('Reminder not scheduled: notifications disabled.');
      return null;
    }
    if (dueCount <= 0) {
      debugPrint('Reminder not scheduled: no reviews due.');
      return null;
    }
    
    final timeStr = "${_settings.hour.toString().padLeft(2, '0')}:${_settings.minute.toString().padLeft(2, '0')}";
    final msg = "$dueCount reviews due — 3 min";
    debugPrint('Notification scheduled for $timeStr: "$msg"');
    return msg;
  }
}
