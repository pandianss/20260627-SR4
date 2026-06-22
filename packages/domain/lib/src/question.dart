import 'localized.dart';

/// How an answer is graded. Drives the grading engine (epic E2) and is
/// validated for consistency against the payload type (E1.3).
enum GradingMode {
  autoExact,
  autoNumeric,
  autoText,
  assistedRubric,
  manual;

  String get wire => switch (this) {
        GradingMode.autoExact => 'auto_exact',
        GradingMode.autoNumeric => 'auto_numeric',
        GradingMode.autoText => 'auto_text',
        GradingMode.assistedRubric => 'assisted_rubric',
        GradingMode.manual => 'manual',
      };

  static GradingMode fromWire(String s) => GradingMode.values.firstWhere(
        (m) => m.wire == s,
        orElse: () => throw FormatException('Unknown gradingMode: $s'),
      );
}

enum AuthoringStatus {
  draft,
  inReview,
  published;

  String get wire => switch (this) {
        AuthoringStatus.draft => 'draft',
        AuthoringStatus.inReview => 'in_review',
        AuthoringStatus.published => 'published',
      };

  static AuthoringStatus fromWire(String s) => AuthoringStatus.values.firstWhere(
        (v) => v.wire == s,
        orElse: () => throw FormatException('Unknown authoring status: $s'),
      );
}

enum PartialCredit {
  none,
  perPair,
  perCorrect,
  jaccard,
  kendallTau;

  String get wire => switch (this) {
        PartialCredit.none => 'none',
        PartialCredit.perPair => 'per_pair',
        PartialCredit.perCorrect => 'per_correct',
        PartialCredit.jaccard => 'jaccard',
        PartialCredit.kendallTau => 'kendall_tau',
      };

  static PartialCredit fromWire(String? s) => s == null
      ? PartialCredit.none
      : PartialCredit.values.firstWhere(
          (v) => v.wire == s,
          orElse: () => PartialCredit.none,
        );
}

enum ToleranceKind {
  absolute,
  relative,
  decimals;

  static ToleranceKind fromWire(String s) => ToleranceKind.values.firstWhere(
        (v) => v.name == s,
        orElse: () => throw FormatException('Unknown tolerance kind: $s'),
      );
}

class QuestionOption {
  final String id;
  final LocalizedString content;

  const QuestionOption({required this.id, required this.content});

  factory QuestionOption.fromJson(Map<String, dynamic> j) => QuestionOption(
        id: j['id'] as String,
        content: LocalizedString.fromJson(j['content']),
      );

  Map<String, dynamic> toJson() => {'id': id, 'content': content.toJson()};
}

class NumericTolerance {
  final ToleranceKind kind;
  final double amount;

  const NumericTolerance({required this.kind, required this.amount});

  factory NumericTolerance.fromJson(Map<String, dynamic> j) => NumericTolerance(
        kind: ToleranceKind.fromWire(j['kind'] as String),
        amount: (j['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'kind': kind.name, 'amount': amount};
}

class NumericStep {
  final String id;
  final LocalizedString prompt;
  final double answer;
  final double tolerance;
  final LocalizedString? hint;

  const NumericStep({
    required this.id,
    required this.prompt,
    required this.answer,
    required this.tolerance,
    this.hint,
  });

  factory NumericStep.fromJson(Map<String, dynamic> j) => NumericStep(
        id: j['id'] as String,
        prompt: LocalizedString.fromJson(j['prompt']),
        answer: (j['answer'] as num).toDouble(),
        tolerance: (j['tolerance'] as num).toDouble(),
        hint: j['hint'] == null ? null : LocalizedString.fromJson(j['hint']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt.toJson(),
        'answer': answer,
        'tolerance': tolerance,
        if (hint != null) 'hint': hint!.toJson(),
      };
}

/// The polymorphic question payload (epic E1.2). One envelope ([QuestionBase]),
/// many formats — a sealed union so the renderer, grader, and validator dispatch
/// on a single discriminant. Adding a format = add one subclass.
sealed class QuestionPayload {
  const QuestionPayload();

  String get type;
  Map<String, dynamic> toJson();

  factory QuestionPayload.fromJson(Map<String, dynamic> j) {
    final type = j['type'] as String;
    return switch (type) {
      'mcq_single' => McqSingle.fromJson(j),
      'true_false' => TrueFalse.fromJson(j),
      'match_pairs' => MatchPairs.fromJson(j),
      'numeric' => NumericEntry.fromJson(j),
      'numeric_multistep' => NumericMultiStep.fromJson(j),
      'passage_ref' => PassageRef.fromJson(j),
      _ => throw FormatException('Unknown question type: $type'),
    };
  }
}

class McqSingle extends QuestionPayload {
  final LocalizedString stem;
  final List<QuestionOption> options;
  final String correctOptionId;

  const McqSingle({
    required this.stem,
    required this.options,
    required this.correctOptionId,
  });

  @override
  String get type => 'mcq_single';

  factory McqSingle.fromJson(Map<String, dynamic> j) => McqSingle(
        stem: LocalizedString.fromJson(j['stem']),
        options: (j['options'] as List)
            .map((e) => QuestionOption.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        correctOptionId: j['correctOptionId'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'stem': stem.toJson(),
        'options': options.map((o) => o.toJson()).toList(),
        'correctOptionId': correctOptionId,
      };
}

class TrueFalse extends QuestionPayload {
  final LocalizedString stem;
  final bool answer;

  const TrueFalse({required this.stem, required this.answer});

  @override
  String get type => 'true_false';

  factory TrueFalse.fromJson(Map<String, dynamic> j) => TrueFalse(
        stem: LocalizedString.fromJson(j['stem']),
        answer: j['answer'] as bool,
      );

  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'stem': stem.toJson(), 'answer': answer};
}

class MatchPairs extends QuestionPayload {
  final LocalizedString stem;
  final List<QuestionOption> left;
  final List<QuestionOption> right;
  final Map<String, String> correct; // leftId -> rightId
  final PartialCredit partialCredit;

  const MatchPairs({
    required this.stem,
    required this.left,
    required this.right,
    required this.correct,
    this.partialCredit = PartialCredit.none,
  });

  @override
  String get type => 'match_pairs';

  factory MatchPairs.fromJson(Map<String, dynamic> j) => MatchPairs(
        stem: LocalizedString.fromJson(j['stem']),
        left: (j['left'] as List)
            .map((e) => QuestionOption.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        right: (j['right'] as List)
            .map((e) => QuestionOption.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        correct: (j['correct'] as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString())),
        partialCredit: PartialCredit.fromWire(j['partialCredit'] as String?),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'stem': stem.toJson(),
        'left': left.map((o) => o.toJson()).toList(),
        'right': right.map((o) => o.toJson()).toList(),
        'correct': correct,
        'partialCredit': partialCredit.wire,
      };
}

class NumericEntry extends QuestionPayload {
  final LocalizedString stem;
  final double answerValue;
  final String? unit;
  final NumericTolerance tolerance;

  const NumericEntry({
    required this.stem,
    required this.answerValue,
    this.unit,
    required this.tolerance,
  });

  @override
  String get type => 'numeric';

  factory NumericEntry.fromJson(Map<String, dynamic> j) {
    final ans = (j['answer'] as Map).cast<String, dynamic>();
    return NumericEntry(
      stem: LocalizedString.fromJson(j['stem']),
      answerValue: (ans['value'] as num).toDouble(),
      unit: ans['unit'] as String?,
      tolerance: NumericTolerance.fromJson(
          (j['tolerance'] as Map).cast<String, dynamic>()),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'stem': stem.toJson(),
        'answer': {'value': answerValue, if (unit != null) 'unit': unit},
        'tolerance': tolerance.toJson(),
      };
}

class NumericMultiStep extends QuestionPayload {
  final LocalizedString stem;
  final List<NumericStep> steps;

  const NumericMultiStep({required this.stem, required this.steps});

  @override
  String get type => 'numeric_multistep';

  factory NumericMultiStep.fromJson(Map<String, dynamic> j) => NumericMultiStep(
        stem: LocalizedString.fromJson(j['stem']),
        steps: (j['steps'] as List)
            .map((e) => NumericStep.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'stem': stem.toJson(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}

/// A sub-question inside a shared stimulus (caselet / passage / DI set). The
/// real question lives in [inner]; the parent [QuestionBase] carries the
/// `stimulusId` that ties it to its [Stimulus].
class PassageRef extends QuestionPayload {
  final String innerType;
  final QuestionPayload inner;

  const PassageRef({required this.innerType, required this.inner});

  @override
  String get type => 'passage_ref';

  factory PassageRef.fromJson(Map<String, dynamic> j) {
    final inner = QuestionPayload.fromJson((j['inner'] as Map).cast<String, dynamic>());
    return PassageRef(
      innerType: j['innerType'] as String? ?? inner.type,
      inner: inner,
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'innerType': innerType, 'inner': inner.toJson()};
}

class Authoring {
  final AuthoringStatus status;
  final String authorId;
  final String? reviewerId;

  const Authoring({
    required this.status,
    required this.authorId,
    this.reviewerId,
  });

  factory Authoring.fromJson(Map<String, dynamic> j) => Authoring(
        status: AuthoringStatus.fromWire(j['status'] as String),
        authorId: j['authorId'] as String,
        reviewerId: j['reviewerId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'status': status.wire,
        'authorId': authorId,
        if (reviewerId != null) 'reviewerId': reviewerId,
      };
}

/// The common envelope every question shares, regardless of [payload] format.
class QuestionBase {
  final String id;
  final int version;
  final List<String> topicTags;
  final int difficulty;
  final GradingMode gradingMode;
  final double defaultMarks;
  final double defaultNegativeMarks;
  final LocalizedString explanation;
  final String? sourceRef;
  final String? stimulusId;
  final Authoring authoring;
  final QuestionPayload payload;

  const QuestionBase({
    required this.id,
    this.version = 1,
    this.topicTags = const [],
    this.difficulty = 1,
    required this.gradingMode,
    this.defaultMarks = 1,
    this.defaultNegativeMarks = 0,
    required this.explanation,
    this.sourceRef,
    this.stimulusId,
    this.authoring =
        const Authoring(status: AuthoringStatus.draft, authorId: 'unknown'),
    required this.payload,
  });

  factory QuestionBase.fromJson(Map<String, dynamic> j) => QuestionBase(
        id: j['id'] as String,
        version: (j['version'] as num?)?.toInt() ?? 1,
        topicTags:
            (j['topicTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        difficulty: (j['difficulty'] as num?)?.toInt() ?? 1,
        gradingMode: GradingMode.fromWire(j['gradingMode'] as String),
        defaultMarks: (j['defaultMarks'] as num?)?.toDouble() ?? 1,
        defaultNegativeMarks: (j['defaultNegativeMarks'] as num?)?.toDouble() ?? 0,
        explanation: LocalizedString.fromJson(j['explanation'] ?? const {}),
        sourceRef: j['sourceRef'] as String?,
        stimulusId: j['stimulusId'] as String?,
        authoring: j['authoring'] == null
            ? const Authoring(status: AuthoringStatus.draft, authorId: 'unknown')
            : Authoring.fromJson((j['authoring'] as Map).cast<String, dynamic>()),
        payload: QuestionPayload.fromJson((j['payload'] as Map).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'topicTags': topicTags,
        'difficulty': difficulty,
        'gradingMode': gradingMode.wire,
        'defaultMarks': defaultMarks,
        'defaultNegativeMarks': defaultNegativeMarks,
        'explanation': explanation.toJson(),
        if (sourceRef != null) 'sourceRef': sourceRef,
        if (stimulusId != null) 'stimulusId': stimulusId,
        'authoring': authoring.toJson(),
        'payload': payload.toJson(),
      };

  QuestionBase withStatus(AuthoringStatus status) => QuestionBase(
        id: id,
        version: version,
        topicTags: topicTags,
        difficulty: difficulty,
        gradingMode: gradingMode,
        defaultMarks: defaultMarks,
        defaultNegativeMarks: defaultNegativeMarks,
        explanation: explanation,
        sourceRef: sourceRef,
        stimulusId: stimulusId,
        authoring: Authoring(
          status: status,
          authorId: authoring.authorId,
          reviewerId: authoring.reviewerId,
        ),
        payload: payload,
      );
}
