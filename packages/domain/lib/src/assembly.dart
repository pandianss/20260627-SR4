import 'question.dart';
import 'exam_config.dart';

/// Assembles a practice mock exam from a bank of questions based on a blueprint (epic E7.1).
List<QuestionBase> assembleMock(MockBlueprint blueprint, List<QuestionBase> questionBank) {
  final List<QuestionBase> assembled = [];

  for (final pick in blueprint.picks) {
    // 1. Filter question bank by topic tags
    final filtered = questionBank.where((q) {
      if (pick.topicTags.isEmpty) return true;
      return q.topicTags.any((tag) => pick.topicTags.contains(tag));
    }).toList();

    // 2. Group by difficulty
    final Map<int, List<QuestionBase>> byDiff = {1: [], 2: [], 3: [], 4: [], 5: []};
    for (final q in filtered) {
      final d = q.difficulty.clamp(1, 5);
      byDiff[d]!.add(q);
    }

    // 3. For each difficulty level, select target count of questions
    final List<QuestionBase> selectedForPick = [];
    for (final entry in pick.difficultyMix.entries) {
      final diff = entry.key;
      final prop = entry.value;
      final target = (pick.count * prop).round();

      final available = byDiff[diff] ?? [];
      if (blueprint.shuffle) {
        available.shuffle();
      }

      final takeCount = target.clamp(0, available.length);
      selectedForPick.addAll(available.take(takeCount));
    }

    // If we didn't meet the target count due to rounding or missing difficulty questions,
    // let's backfill from the remaining filtered questions that were not selected yet.
    if (selectedForPick.length < pick.count) {
      final remaining = filtered.where((q) => !selectedForPick.contains(q)).toList();
      if (blueprint.shuffle) {
        remaining.shuffle();
      }
      final needed = pick.count - selectedForPick.length;
      selectedForPick.addAll(remaining.take(needed.clamp(0, remaining.length)));
    }

    assembled.addAll(selectedForPick);
  }

  // 4. Honor overall shuffle
  if (blueprint.shuffle) {
    assembled.shuffle();
  }

  // 5. Ensure that questions sharing a stimulusId are grouped together sequentially
  final List<QuestionBase> grouped = [];
  final Set<String?> processedStimulusIds = {};

  for (final q in assembled) {
    if (q.stimulusId == null) {
      grouped.add(q);
    } else {
      if (processedStimulusIds.contains(q.stimulusId)) {
        continue;
      }
      processedStimulusIds.add(q.stimulusId);
      // Group all questions from the assembled list sharing this stimulusId
      final siblings = assembled.where((item) => item.stimulusId == q.stimulusId).toList();
      grouped.addAll(siblings);
    }
  }

  return grouped;
}
