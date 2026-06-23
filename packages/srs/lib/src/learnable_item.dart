enum LearnableItemKind { card, question }

/// A spaced-repetition item scheduled for retrieval reviews (epic E3.2).
/// Wraps either an srsEligible concept Card or a standalone Question.
class LearnableItem {
  final String id;
  final LearnableItemKind kind;
  final String refId; // Card.id or Question.id
  final List<String> probeQuestionIds; // for cards: how to test recall (rotate to avoid memorising)
  final List<String> topicTags;
  final List<String> examContexts; // which exams this item serves

  const LearnableItem({
    required this.id,
    required this.kind,
    required this.refId,
    this.probeQuestionIds = const [],
    this.topicTags = const [],
    this.examContexts = const [],
  });

  factory LearnableItem.fromJson(Map<String, dynamic> j) => LearnableItem(
        id: j['id'] as String,
        kind: LearnableItemKind.values.byName(j['kind'] as String),
        refId: j['refId'] as String,
        probeQuestionIds:
            (j['probeQuestionIds'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        topicTags:
            (j['topicTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        examContexts:
            (j['examContexts'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'refId': refId,
        'probeQuestionIds': probeQuestionIds,
        'topicTags': topicTags,
        'examContexts': examContexts,
      };
}
