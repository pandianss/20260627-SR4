import 'dart:math' as math;

import 'learnable_item.dart';
import 'srs_state.dart';

class _ScoredState {
  final SrsState state;
  final double priorityScore;
  final String topic;

  _ScoredState({
    required this.state,
    required this.priorityScore,
    required this.topic,
  });
}

/// Builds the daily due review queue, interleaved by topic and weighted by
/// priority and learner weakness (epic E3.4).
List<SrsState> buildDueQueue({
  required List<SrsState> states,
  required Map<String, LearnableItem> items,
  required DateTime now,
  required int budget,
  Map<String, double>? topicAccuracy,
  Map<String, double>? topicWeights,
}) {
  if (states.isEmpty || budget <= 0) {
    return const [];
  }

  // 1. Filter states for due items (due <= now) and score them
  final List<_ScoredState> scoredStates = [];
  for (final state in states) {
    // Only due items
    if (state.due.isAfter(now)) {
      continue;
    }

    // Determine topic tag
    final item = items[state.itemId];
    final String topic = (item != null && item.topicTags.isNotEmpty)
        ? item.topicTags.first
        : 'default';

    // Priority Score Calculation:
    // For reviewed items, calculate FSRS overdue ratio: (now - due) / stability.
    // Lapsed (relearning) items get a +10.0 priority bump.
    // Explicit high-priority items (mock errors) get a +20.0 priority bump.
    double basePriority = 0.0;
    if (state.reps > 0) {
      final overdueDays = now.difference(state.due).inSeconds / 86400.0;
      final stability = math.max(0.1, state.stability);
      basePriority = math.max(0.0, overdueDays / stability);
    } else {
      // New item baseline priority
      basePriority = 1.0;
    }

    if (state.phase == SrsPhase.relearning) {
      basePriority += 10.0;
    }
    if (state.isHighPriority) {
      basePriority += 20.0;
    }

    // Apply topic accuracy and weights multipliers
    final double accuracy = topicAccuracy?[topic] ?? 1.0;
    // Lower accuracy (learner weakness) increases priority (up to 3x multiplier)
    final double accuracyMultiplier = 1.0 + (1.0 - accuracy.clamp(0.0, 1.0)) * 2.0;
    final double directWeight = topicWeights?[topic] ?? 1.0;

    final priorityScore = basePriority * accuracyMultiplier * directWeight;

    scoredStates.add(_ScoredState(
      state: state,
      priorityScore: priorityScore,
      topic: topic,
    ));
  }

  if (scoredStates.isEmpty) {
    return const [];
  }

  // 2. Group by topic and sort each group by priority score (descending)
  final Map<String, List<_ScoredState>> groups = {};
  for (final scored in scoredStates) {
    groups.putIfAbsent(scored.topic, () => []).add(scored);
  }

  for (final list in groups.values) {
    list.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
  }

  // 3. Interleave topics using a round-robin selector that avoids consecutive duplicates
  final List<SrsState> result = [];
  String? lastSelectedTopic;

  while (result.length < budget) {
    // Identify active topics that still have items
    final activeTopics = groups.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toList();

    if (activeTopics.isEmpty) {
      break;
    }

    // Filter candidates to avoid consecutive duplicates of the same topic
    List<String> candidates = activeTopics;
    if (activeTopics.length > 1 && lastSelectedTopic != null) {
      candidates = activeTopics.where((t) => t != lastSelectedTopic).toList();
    }

    // Pick the candidate topic whose next item has the highest priority score
    String selectedTopic = candidates.first;
    double maxPriority = groups[selectedTopic]!.first.priorityScore;

    for (final topic in candidates) {
      final priority = groups[topic]!.first.priorityScore;
      if (priority > maxPriority) {
        maxPriority = priority;
        selectedTopic = topic;
      }
    }

    // Dequeue the item
    final popped = groups[selectedTopic]!.removeAt(0);
    result.add(popped.state);
    lastSelectedTopic = selectedTopic;
  }

  return result;
}
