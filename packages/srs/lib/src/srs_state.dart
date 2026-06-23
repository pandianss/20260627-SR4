/// The learner's rating of a recall attempt (FSRS grades 1..4).
enum Rating {
  again,
  hard,
  good,
  easy;

  int get grade => index + 1;
}

enum SrsPhase { newItem, learning, review, relearning }

/// Per-(user, item) spaced-repetition memory state (FSRS model). Persisted by
/// the offline store (epic E4) and projected from the event log on the server.
class SrsState {
  final double stability; // S — expected memory horizon, in days
  final double difficulty; // D — 1..10
  final DateTime due;
  final DateTime lastReview;
  final int reps;
  final int lapses;
  final SrsPhase phase;
  final String userId;
  final String itemId;
  final String examContext;
  final bool isHighPriority; // e.g. set on mock errors to prioritize relearning

  const SrsState({
    required this.stability,
    required this.difficulty,
    required this.due,
    required this.lastReview,
    this.reps = 0,
    this.lapses = 0,
    this.phase = SrsPhase.newItem,
    this.userId = '',
    this.itemId = '',
    this.examContext = '',
    this.isHighPriority = false,
  });

  SrsState copyWith({
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
    int? reps,
    int? lapses,
    SrsPhase? phase,
    String? userId,
    String? itemId,
    String? examContext,
    bool? isHighPriority,
  }) =>
      SrsState(
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        due: due ?? this.due,
        lastReview: lastReview ?? this.lastReview,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        phase: phase ?? this.phase,
        userId: userId ?? this.userId,
        itemId: itemId ?? this.itemId,
        examContext: examContext ?? this.examContext,
        isHighPriority: isHighPriority ?? this.isHighPriority,
      );

  factory SrsState.fromJson(Map<String, dynamic> j) => SrsState(
        stability: (j['stability'] as num).toDouble(),
        difficulty: (j['difficulty'] as num).toDouble(),
        due: DateTime.parse(j['due'] as String),
        lastReview: DateTime.parse(j['lastReview'] as String),
        reps: (j['reps'] as num?)?.toInt() ?? 0,
        lapses: (j['lapses'] as num?)?.toInt() ?? 0,
        phase: SrsPhase.values.byName(j['phase'] as String? ?? 'newItem'),
        userId: j['userId'] as String? ?? '',
        itemId: j['itemId'] as String? ?? '',
        examContext: j['examContext'] as String? ?? '',
        isHighPriority: j['isHighPriority'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'stability': stability,
        'difficulty': difficulty,
        'due': due.toUtc().toIso8601String(),
        'lastReview': lastReview.toUtc().toIso8601String(),
        'reps': reps,
        'lapses': lapses,
        'phase': phase.name,
        'userId': userId,
        'itemId': itemId,
        'examContext': examContext,
        'isHighPriority': isHighPriority,
      };
}
