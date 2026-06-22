import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';
import 'package:grading/grading.dart';
import 'package:test/test.dart';

void main() {
  group('JAIIB exam config', () {
    late ExamConfig config;

    setUpAll(() {
      final file = File('../../content/exams/jaiib.config.json');
      config = ExamConfig.fromJson(
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
    });

    test('loads four compulsory papers, 100 MCQ, no negative marking', () {
      expect(config.examCode, 'JAIIB');
      expect(config.papers, hasLength(4));
      final ppb = config.paper('PPB');
      expect(ppb, isNotNull);
      final section = ppb!.sections.single;
      expect(section.count, 100);
      expect(section.marksPerQuestion, 1);
      expect(section.negativeMarks, 0);
    });

    test('carries the two-path pass rule', () {
      expect(config.passRule.perComponentMin, 50);
      expect(config.passRule.alternativeAggregate?.perComponentMin, 45);
      expect(config.passRule.alternativeAggregate?.aggregateMin, 50);
      expect(config.gradingProfile.allowPartialDefault, isFalse);
    });

    test('round-trips through json', () {
      final again = ExamConfig.fromJson(
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>);
      expect(again.toJson(), equals(config.toJson()));
    });
  });

  group('pass-rule evaluation', () {
    final rule = const PassRule(
      perComponentMin: 50,
      alternativeAggregate:
          AlternativeAggregate(perComponentMin: 45, aggregateMin: 50),
    );

    List<ComponentScore> comps(List<double> percents) => [
          for (var i = 0; i < percents.length; i++)
            ComponentScore(code: 'P$i', scored: percents[i], max: 100),
        ];

    test('path 1: every component >= 50 passes', () {
      final out = evaluatePass(comps([55, 60, 50, 72]), rule);
      expect(out.passed, isTrue);
      expect(out.reason, contains('Each component'));
    });

    test('path 2: a 47 with a >=50 aggregate passes', () {
      final out = evaluatePass(comps([50, 50, 47, 60]), rule);
      expect(out.passed, isTrue);
      expect(out.aggregatePercent, closeTo(51.75, 1e-9));
      expect(out.reason, contains('Aggregate path'));
    });

    test('a component below 45 fails both paths', () {
      final out = evaluatePass(comps([40, 60, 60, 60]), rule);
      expect(out.passed, isFalse);
    });
  });
}
