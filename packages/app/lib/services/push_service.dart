import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Subscribes the device to the `regulatory-updates` FCM topic so it receives
/// the pushes sent by the `refreshUpdates` Cloud Function when a new
/// critical/important regulatory update is curated.
///
/// Best-effort: failures (offline, permission denied, unsupported platform) are
/// swallowed — push is an enhancement, not a hard dependency.
class PushService {
  static const topic = 'regulatory-updates';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Web requires VAPID-key setup we don't ship; topic messaging is mobile-only here.
    if (kIsWeb) return;
    try {
      // On iOS / Android 13+ this surfaces the system permission prompt; on
      // older Android it's a no-op. Subscription works regardless of the result
      // (permission only gates whether the notification is *displayed*).
      await _messaging.requestPermission();
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('PushService.init failed: $e');
    }
  }
}
