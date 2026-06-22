import 'content.dart' show PaperKind;
import 'localized.dart';

/// Declarative, per-exam configuration (technical-spec §6). The engine reads
/// exam rules from here; it never hard-codes them. Adding an exam = a content
/// pack + one of these documents.

class GradingProfile {
  final bool allowPartialDefault;

  /// 'off' | 'assisted' | 'manual'. For the IIBF scope this is always 'off'.
  final String descriptiveGrading;

  const GradingProfile({
    this.allowPartialDefault = false,
    this.descriptiveGrading = 'off',
  });

  factory GradingProfile.fromJson(Map<String, dynamic> j) => GradingProfile(
        allowPartialDefault: j['allowPartialDefault'] as bool? ?? false,
        descriptiveGrading: j['descriptiveGrading'] as String? ?? 'off',
      );

  Map<String, dynamic> toJson() => {
        'allowPartialDefault': allowPartialDefault,
        'descriptiveGrading': descriptiveGrading,
      };
}

class SectionConfig {
  final String code;
  final LocalizedString name;
  final List<String> allowedTypes;
  final int count;
  final double marksPerQuestion;
  final double negativeMarks;
  final int? durationMin;
  final double? cutoff;

  const SectionConfig({
    required this.code,
    this.name = const LocalizedString({}),
    this.allowedTypes = const [],
    required this.count,
    this.marksPerQuestion = 1,
    this.negativeMarks = 0,
    this.durationMin,
    this.cutoff,
  });

  factory SectionConfig.fromJson(Map<String, dynamic> j) => SectionConfig(
        code: j['code'] as String,
        name: LocalizedString.fromJson(j['name'] ?? const {}),
        allowedTypes:
            (j['allowedTypes'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        count: (j['count'] as num).toInt(),
        marksPerQuestion: (j['marksPerQuestion'] as num?)?.toDouble() ?? 1,
        negativeMarks: (j['negativeMarks'] as num?)?.toDouble() ?? 0,
        durationMin: (j['durationMin'] as num?)?.toInt(),
        cutoff: (j['cutoff'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name.toJson(),
        'allowedTypes': allowedTypes,
        'count': count,
        'marksPerQuestion': marksPerQuestion,
        'negativeMarks': negativeMarks,
        if (durationMin != null) 'durationMin': durationMin,
        if (cutoff != null) 'cutoff': cutoff,
      };
}

class PaperConfig {
  final String paperCode;
  final LocalizedString name;
  final PaperKind kind;
  final int durationMin;
  final bool sectionalTiming;
  final List<String> electiveOptions;
  final List<SectionConfig> sections;

  const PaperConfig({
    required this.paperCode,
    this.name = const LocalizedString({}),
    this.kind = PaperKind.compulsory,
    this.durationMin = 120,
    this.sectionalTiming = false,
    this.electiveOptions = const [],
    this.sections = const [],
  });

  factory PaperConfig.fromJson(Map<String, dynamic> j) => PaperConfig(
        paperCode: j['paperCode'] as String,
        name: LocalizedString.fromJson(j['name'] ?? const {}),
        kind: PaperKind.fromWire(j['kind'] as String? ?? 'compulsory'),
        durationMin: (j['durationMin'] as num?)?.toInt() ?? 120,
        sectionalTiming: j['sectionalTiming'] as bool? ?? false,
        electiveOptions: (j['electiveOptions'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        sections: (j['sections'] as List?)
                ?.map((e) =>
                    SectionConfig.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'paperCode': paperCode,
        'name': name.toJson(),
        'kind': kind.name,
        'durationMin': durationMin,
        'sectionalTiming': sectionalTiming,
        if (electiveOptions.isNotEmpty) 'electiveOptions': electiveOptions,
        'sections': sections.map((s) => s.toJson()).toList(),
      };
}

/// The alternative pass path, e.g. JAIIB's "45 in each subject with a 50%
/// aggregate in a single attempt".
class AlternativeAggregate {
  final double perComponentMin;
  final double aggregateMin;

  const AlternativeAggregate({
    required this.perComponentMin,
    required this.aggregateMin,
  });

  factory AlternativeAggregate.fromJson(Map<String, dynamic> j) =>
      AlternativeAggregate(
        perComponentMin: (j['perComponentMin'] as num).toDouble(),
        aggregateMin: (j['aggregateMin'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'perComponentMin': perComponentMin,
        'aggregateMin': aggregateMin,
      };
}

class PassRule {
  /// Minimum percentage required in each component (subject/paper).
  final double? perComponentMin;
  final AlternativeAggregate? alternativeAggregate;
  final double? overallMin;
  final bool carryForward;

  const PassRule({
    this.perComponentMin,
    this.alternativeAggregate,
    this.overallMin,
    this.carryForward = false,
  });

  factory PassRule.fromJson(Map<String, dynamic> j) => PassRule(
        perComponentMin: (j['perComponentMin'] as num?)?.toDouble(),
        alternativeAggregate: j['alternativeAggregate'] == null
            ? null
            : AlternativeAggregate.fromJson(
                (j['alternativeAggregate'] as Map).cast<String, dynamic>()),
        overallMin: (j['overallMin'] as num?)?.toDouble(),
        carryForward: j['carryForward'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (perComponentMin != null) 'perComponentMin': perComponentMin,
        if (alternativeAggregate != null)
          'alternativeAggregate': alternativeAggregate!.toJson(),
        if (overallMin != null) 'overallMin': overallMin,
        'carryForward': carryForward,
      };
}

class ExamConfig {
  final String examCode;
  final int version;
  final List<String> languages;
  final List<PaperConfig> papers;
  final PassRule passRule;
  final GradingProfile gradingProfile;

  const ExamConfig({
    required this.examCode,
    this.version = 1,
    this.languages = const ['en'],
    this.papers = const [],
    this.passRule = const PassRule(),
    this.gradingProfile = const GradingProfile(),
  });

  factory ExamConfig.fromJson(Map<String, dynamic> j) => ExamConfig(
        examCode: j['examCode'] as String,
        version: (j['version'] as num?)?.toInt() ?? 1,
        languages:
            (j['languages'] as List?)?.map((e) => e.toString()).toList() ??
                const ['en'],
        papers: (j['papers'] as List?)
                ?.map((e) =>
                    PaperConfig.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        passRule: j['passRule'] == null
            ? const PassRule()
            : PassRule.fromJson((j['passRule'] as Map).cast<String, dynamic>()),
        gradingProfile: j['gradingProfile'] == null
            ? const GradingProfile()
            : GradingProfile.fromJson(
                (j['gradingProfile'] as Map).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        'examCode': examCode,
        'version': version,
        'languages': languages,
        'papers': papers.map((p) => p.toJson()).toList(),
        'passRule': passRule.toJson(),
        'gradingProfile': gradingProfile.toJson(),
      };

  PaperConfig? paper(String code) {
    for (final p in papers) {
      if (p.paperCode == code) return p;
    }
    return null;
  }
}
