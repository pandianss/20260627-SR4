import 'package:flutter/foundation.dart';

class TelemetryLog {
  final DateTime timestamp;
  final String level; // 'INFO' | 'ERROR'
  final String message;
  final String? stackTrace;

  const TelemetryLog({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] [$level] $message${stackTrace != null ? "\n$stackTrace" : ""}';
  }
}

class TelemetryService {
  final List<TelemetryLog> _logs = [];
  Duration? _bootLatency;

  Duration? get bootLatency => _bootLatency;

  void setBootLatency(Duration latency) {
    _bootLatency = latency;
    logInfo('App boot latency measured: ${latency.inMilliseconds}ms');
  }

  void logInfo(String message) {
    final log = TelemetryLog(
      timestamp: DateTime.now(),
      level: 'INFO',
      message: message,
    );
    _logs.add(log);
    debugPrint(log.toString());
  }

  void logError(dynamic error, [StackTrace? stackTrace]) {
    final log = TelemetryLog(
      timestamp: DateTime.now(),
      level: 'ERROR',
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
    );
    _logs.add(log);
    debugPrint(log.toString());
  }

  List<TelemetryLog> getLogs() => List.unmodifiable(_logs);

  void clearLogs() {
    _logs.clear();
  }
}
