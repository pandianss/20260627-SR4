import 'srs_state.dart';

/// Pluggable spaced-repetition scheduler (epic E3.1). FSRS is the default
/// implementation; SM-2 or a deadline-aware decorator can be swapped in without
/// touching callers.
abstract interface class Scheduler {
  /// State after the very first review of a brand-new item.
  SrsState init(DateTime now, Rating rating);

  /// State after reviewing an existing item.
  SrsState review(SrsState state, Rating rating, DateTime now);
}
