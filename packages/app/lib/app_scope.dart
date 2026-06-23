import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'data/learning_repository.dart';
import 'services/notification_service.dart';

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

  const AppScope({
    super.key,
    required this.repository,
    required this.userId,
    required this.examName,
    required this.examDate,
    required this.examConfig,
    required this.notificationService,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope.of() called with no AppScope ancestor.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
