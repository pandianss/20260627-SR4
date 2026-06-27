import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'data/learning_repository.dart';
import 'services/notification_service.dart';
import 'services/updates_service.dart';
import 'services/auth_service.dart';
import 'services/billing_service.dart';

/// App-wide dependencies made available to the screen tree, so screens read
/// what they need from context instead of receiving a long list of constructor
/// parameters. Stable for a session, so it never triggers dependent rebuilds.
class AppScope extends InheritedWidget {
  final LearningRepository repository;
  final String userId;
  final String examName;
  final DateTime examDate;
  final ExamConfig examConfig;
  final NotificationService notificationService;
  final UpdatesService updatesService;
  final AuthService? authService;
  final VoidCallback? onLogout;
  final Future<void> Function()? onDeleteAccount;

  /// Bumps when remote (multi-device) changes have merged into local data, so
  /// screens can reload. Null when live sync isn't active.
  final Listenable? syncRevision;

  /// Ask the app to push local changes to the cloud soon (debounced).
  final VoidCallback? requestSync;
  final bool isPremium;
  final VoidCallback? onBuyPremium;

  /// Play Billing / StoreKit access for the paywall. Null when unavailable.
  final BillingService? billingService;
  final ThemeMode themeMode;
  final void Function(ThemeMode mode)? onSetThemeMode;

  const AppScope({
    super.key,
    required this.repository,
    required this.userId,
    required this.examName,
    required this.examDate,
    required this.examConfig,
    required this.notificationService,
    required this.updatesService,
    this.authService,
    this.onLogout,
    this.onDeleteAccount,
    this.syncRevision,
    this.requestSync,
    required this.isPremium,
    this.onBuyPremium,
    this.billingService,
    this.themeMode = ThemeMode.system,
    this.onSetThemeMode,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope.of() called with no AppScope ancestor.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.isPremium != isPremium ||
      oldWidget.userId != userId ||
      oldWidget.examName != examName ||
      oldWidget.themeMode != themeMode;
}
