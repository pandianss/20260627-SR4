import 'package:flutter/foundation.dart';

/// How prominently an update should be surfaced. Drives chip colour and (later)
/// whether it triggers a push notification.
enum UpdatePriority { critical, important, normal }

UpdatePriority _priorityFrom(String? raw) {
  switch (raw) {
    case 'critical':
      return UpdatePriority.critical;
    case 'important':
      return UpdatePriority.important;
    default:
      return UpdatePriority.normal;
  }
}

/// A single curated update from a financial regulator (RBI, SEBI, IRDAI, IIBF…),
/// summarised in plain language and linked back to the official source.
@immutable
class RegulatoryUpdate {
  final String id;
  final String regulator;
  final String title;
  final String summary;
  final String category;
  final UpdatePriority priority;
  final DateTime publishedAt;
  final String? sourceUrl;

  /// Syllabus topic slugs this update touches — used (later) to deep-link an
  /// update to the affected lesson/module.
  final List<String> affectsTopics;

  const RegulatoryUpdate({
    required this.id,
    required this.regulator,
    required this.title,
    required this.summary,
    required this.category,
    required this.priority,
    required this.publishedAt,
    this.sourceUrl,
    this.affectsTopics = const [],
  });

  factory RegulatoryUpdate.fromJson(Map<String, dynamic> json) {
    return RegulatoryUpdate(
      id: json['id'] as String,
      regulator: (json['regulator'] as String?) ?? 'Update',
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      priority: _priorityFrom(json['priority'] as String?),
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      sourceUrl: json['sourceUrl'] as String?,
      affectsTopics:
          (json['affectsTopics'] as List?)?.cast<String>() ?? const [],
    );
  }
}

/// A versioned bundle of updates, as published by the curated feed (or shipped
/// as a bundled seed). Updates are exposed newest-first.
@immutable
class UpdatesFeed {
  final int version;
  final DateTime? generatedAt;
  final List<RegulatoryUpdate> updates;

  const UpdatesFeed({
    required this.version,
    required this.generatedAt,
    required this.updates,
  });

  static const empty =
      UpdatesFeed(version: 0, generatedAt: null, updates: []);

  factory UpdatesFeed.fromJson(Map<String, dynamic> json) {
    final raw = (json['updates'] as List?) ?? const [];
    final updates = raw
        .map((e) => RegulatoryUpdate.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return UpdatesFeed(
      version: (json['version'] as num?)?.toInt() ?? 0,
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? ''),
      updates: updates,
    );
  }
}
