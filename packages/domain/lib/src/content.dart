import 'localized.dart';

/// A block of teaching content inside a [Card]. Sealed so the lesson renderer
/// dispatches on a single discriminant (epic E1.1).
sealed class ContentBlock {
  const ContentBlock();

  String get kind;
  Map<String, dynamic> toJson();

  factory ContentBlock.fromJson(Map<String, dynamic> j) {
    final kind = j['kind'] as String;
    return switch (kind) {
      'text' => TextBlock.fromJson(j),
      'image' || 'animation' || 'audio' => MediaBlock.fromJson(j),
      'formula' => FormulaBlock.fromJson(j),
      'chart' => ChartBlock.fromJson(j),
      _ => throw FormatException('Unknown content block kind: $kind'),
    };
  }
}

class TextBlock extends ContentBlock {
  final LocalizedString md;
  const TextBlock(this.md);

  @override
  String get kind => 'text';

  factory TextBlock.fromJson(Map<String, dynamic> j) =>
      TextBlock(LocalizedString.fromJson(j['md']));

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'md': md.toJson()};
}

class MediaBlock extends ContentBlock {
  final String mediaKind; // image | animation | audio
  final String assetId;
  final LocalizedString alt;

  const MediaBlock({
    required this.mediaKind,
    required this.assetId,
    required this.alt,
  });

  @override
  String get kind => mediaKind;

  factory MediaBlock.fromJson(Map<String, dynamic> j) => MediaBlock(
        mediaKind: j['kind'] as String,
        assetId: j['assetId'] as String,
        alt: LocalizedString.fromJson(j['alt'] ?? const {}),
      );

  @override
  Map<String, dynamic> toJson() =>
      {'kind': mediaKind, 'assetId': assetId, 'alt': alt.toJson()};
}

class FormulaBlock extends ContentBlock {
  final String latex;
  const FormulaBlock(this.latex);

  @override
  String get kind => 'formula';

  factory FormulaBlock.fromJson(Map<String, dynamic> j) =>
      FormulaBlock(j['latex'] as String);

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'latex': latex};
}

class ChartBlock extends ContentBlock {
  final Map<String, dynamic> spec;
  const ChartBlock(this.spec);

  @override
  String get kind => 'chart';

  factory ChartBlock.fromJson(Map<String, dynamic> j) =>
      ChartBlock((j['spec'] as Map).cast<String, dynamic>());

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'spec': spec};
}

enum CardKind {
  intro,
  concept,
  example,
  recap;

  static CardKind fromWire(String s) => CardKind.values.firstWhere(
        (v) => v.name == s,
        orElse: () => throw FormatException('Unknown card kind: $s'),
      );
}

/// One micro-content card. Concept/example cards with [srsEligible] become
/// long-term spaced-repetition items (epic E3).
class Card {
  final String id;
  final CardKind kind;
  final List<ContentBlock> blocks;
  final bool srsEligible;

  const Card({
    required this.id,
    required this.kind,
    required this.blocks,
    this.srsEligible = false,
  });

  factory Card.fromJson(Map<String, dynamic> j) => Card(
        id: j['id'] as String,
        kind: CardKind.fromWire(j['kind'] as String),
        blocks: (j['blocks'] as List)
            .map((e) => ContentBlock.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        srsEligible: j['srsEligible'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'srsEligible': srsEligible,
      };
}

/// The unit a learner finishes in one sitting (~5 min). Holds teaching [cards]
/// and references retrieval questions by id from the shared question bank.
class Lesson {
  final String id;
  final String moduleId;
  final LocalizedString title;
  final int estMinutes;
  final int version;
  final List<Card> cards;
  final List<String> probeQuestionIds;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.estMinutes = 5,
    this.version = 1,
    this.cards = const [],
    this.probeQuestionIds = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        moduleId: j['moduleId'] as String,
        title: LocalizedString.fromJson(j['title']),
        estMinutes: (j['estMinutes'] as num?)?.toInt() ?? 5,
        version: (j['version'] as num?)?.toInt() ?? 1,
        cards: (j['cards'] as List?)
                ?.map((e) => Card.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        probeQuestionIds:
            (j['probeQuestionIds'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title.toJson(),
        'estMinutes': estMinutes,
        'version': version,
        'cards': cards.map((c) => c.toJson()).toList(),
        'probeQuestionIds': probeQuestionIds,
      };
}

class Module {
  final String id;
  final String paperId;
  final LocalizedString name;
  final List<String> topicTags;
  final List<String> lessonIds;

  const Module({
    required this.id,
    required this.paperId,
    required this.name,
    this.topicTags = const [],
    this.lessonIds = const [],
  });

  factory Module.fromJson(Map<String, dynamic> j) => Module(
        id: j['id'] as String,
        paperId: j['paperId'] as String,
        name: LocalizedString.fromJson(j['name']),
        topicTags:
            (j['topicTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        lessonIds:
            (j['lessonIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'paperId': paperId,
        'name': name.toJson(),
        'topicTags': topicTags,
        'lessonIds': lessonIds,
      };
}

enum PaperKind {
  compulsory,
  elective;

  static PaperKind fromWire(String s) => PaperKind.values.firstWhere(
        (v) => v.name == s,
        orElse: () => PaperKind.compulsory,
      );
}

class Paper {
  final String id;
  final String examCode;
  final LocalizedString name;
  final PaperKind kind;
  final List<String> moduleIds;
  final List<String> electiveOptions;

  const Paper({
    required this.id,
    required this.examCode,
    required this.name,
    this.kind = PaperKind.compulsory,
    this.moduleIds = const [],
    this.electiveOptions = const [],
  });

  factory Paper.fromJson(Map<String, dynamic> j) => Paper(
        id: j['id'] as String,
        examCode: j['examCode'] as String,
        name: LocalizedString.fromJson(j['name']),
        kind: PaperKind.fromWire(j['kind'] as String? ?? 'compulsory'),
        moduleIds:
            (j['moduleIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        electiveOptions: (j['electiveOptions'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'examCode': examCode,
        'name': name.toJson(),
        'kind': kind.name,
        'moduleIds': moduleIds,
        if (electiveOptions.isNotEmpty) 'electiveOptions': electiveOptions,
      };
}

enum ExamStatus {
  draft,
  published;

  static ExamStatus fromWire(String s) => ExamStatus.values.firstWhere(
        (v) => v.name == s,
        orElse: () => ExamStatus.draft,
      );
}

class Exam {
  final String id;
  final String code;
  final String name;
  final String body;
  final List<String> languages;
  final String configId;
  final List<String> paperIds;
  final ExamStatus status;
  final int version;

  const Exam({
    required this.id,
    required this.code,
    required this.name,
    required this.body,
    this.languages = const ['en'],
    this.configId = '',
    this.paperIds = const [],
    this.status = ExamStatus.draft,
    this.version = 1,
  });

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] as String,
        code: j['code'] as String,
        name: j['name'] as String,
        body: j['body'] as String? ?? '',
        languages:
            (j['languages'] as List?)?.map((e) => e.toString()).toList() ??
                const ['en'],
        configId: j['configId'] as String? ?? '',
        paperIds:
            (j['paperIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        status: ExamStatus.fromWire(j['status'] as String? ?? 'draft'),
        version: (j['version'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'body': body,
        'languages': languages,
        'configId': configId,
        'paperIds': paperIds,
        'status': status.name,
        'version': version,
      };
}

enum AssetKind {
  image,
  animation,
  audio,
  chart;

  static AssetKind fromWire(String s) => AssetKind.values.firstWhere(
        (v) => v.name == s,
        orElse: () => AssetKind.image,
      );
}

class Asset {
  final String id;
  final AssetKind kind;
  final String url;
  final LocalizedString alt;
  final String? checksum;

  const Asset({
    required this.id,
    required this.kind,
    required this.url,
    required this.alt,
    this.checksum,
  });

  factory Asset.fromJson(Map<String, dynamic> j) => Asset(
        id: j['id'] as String,
        kind: AssetKind.fromWire(j['kind'] as String? ?? 'image'),
        url: j['url'] as String? ?? '',
        alt: LocalizedString.fromJson(j['alt'] ?? const {}),
        checksum: j['checksum'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'url': url,
        'alt': alt.toJson(),
        if (checksum != null) 'checksum': checksum,
      };
}

enum StimulusKind {
  passage,
  chart,
  table,
  caselet;

  static StimulusKind fromWire(String s) => StimulusKind.values.firstWhere(
        (v) => v.name == s,
        orElse: () => throw FormatException('Unknown stimulus kind: $s'),
      );
}

/// A shared stimulus (caselet / passage / DI set) referenced by several
/// `passage_ref` questions. Authored once, scored as a unit (epic E1.1).
class Stimulus {
  final String id;
  final StimulusKind kind;
  final LocalizedString content;
  final String? assetId;
  final Map<String, dynamic>? chartSpec;
  final List<String> childQuestionIds;

  const Stimulus({
    required this.id,
    required this.kind,
    required this.content,
    this.assetId,
    this.chartSpec,
    this.childQuestionIds = const [],
  });

  factory Stimulus.fromJson(Map<String, dynamic> j) => Stimulus(
        id: j['id'] as String,
        kind: StimulusKind.fromWire(j['kind'] as String),
        content: LocalizedString.fromJson(j['content'] ?? const {}),
        assetId: j['assetId'] as String?,
        chartSpec: j['chartSpec'] == null
            ? null
            : (j['chartSpec'] as Map).cast<String, dynamic>(),
        childQuestionIds: (j['childQuestionIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'content': content.toJson(),
        if (assetId != null) 'assetId': assetId,
        if (chartSpec != null) 'chartSpec': chartSpec,
        'childQuestionIds': childQuestionIds,
      };
}
