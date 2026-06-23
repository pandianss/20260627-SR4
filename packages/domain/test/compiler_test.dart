import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import '../bin/compile_content.dart';

void main() {
  group('Content Compiler & Workflow Tests', () {
    late Directory tempSrc;
    late Directory tempOut;
    late String outFilePath;

    setUp(() async {
      tempSrc = await Directory.systemTemp.createTemp('cms_src_test');
      tempOut = await Directory.systemTemp.createTemp('cms_out_test');
      outFilePath = '${tempOut.path}/content_pack.json';
    });

    tearDown(() async {
      await tempSrc.delete(recursive: true);
      await tempOut.delete(recursive: true);
    });

    test('compiles valid structural metadata and published sign-off content', () async {
      // 1. Structural Exam
      final examFile = File('${tempSrc.path}/exam.json');
      await examFile.writeAsString(jsonEncode({
        'contentType': 'exam',
        'id': 'ex_test',
        'code': 'TEST',
        'name': 'Test Exam',
        'body': 'Test Body',
      }));

      // 2. Published Lesson with proper sign-off
      final lessonFile = File('${tempSrc.path}/lesson.json');
      await lessonFile.writeAsString(jsonEncode({
        'contentType': 'lesson',
        'status': 'published',
        'author': 'sme_author',
        'reviewedBy': 'sme_reviewer',
        'id': 'les_test',
        'moduleId': 'mod_test',
        'title': {'en': 'Test Lesson'},
        'estMinutes': 5,
        'cards': [
          // Need 4-6 cards to be valid under ContentValidator guidelines (or warnings are ignored, only errors block publishing)
          // Wait, ContentValidator.validateLesson returns warnings for cards < 4. Let's provide 4 cards to be warning-free,
          // though warnings don't block publishing (publishable is true if errors is empty). Let's provide 4 cards.
          {'id': 'c1', 'kind': 'intro', 'blocks': [{'kind': 'text', 'md': {'en': 'Block 1'}}]},
          {'id': 'c2', 'kind': 'concept', 'blocks': [{'kind': 'text', 'md': {'en': 'Block 2'}}, {'kind': 'formula', 'latex': 'x=1'}]},
          {'id': 'c3', 'kind': 'example', 'blocks': [{'kind': 'text', 'md': {'en': 'Block 3'}}, {'kind': 'chart', 'spec': {}}]},
          {'id': 'c4', 'kind': 'recap', 'blocks': [{'kind': 'text', 'md': {'en': 'Block 4'}}]}
        ],
        'probeQuestionIds': ['q_test']
      }));

      // 3. Published Question with proper sign-off
      final questionFile = File('${tempSrc.path}/question.json');
      await questionFile.writeAsString(jsonEncode({
        'contentType': 'question',
        'id': 'q_test',
        'gradingMode': 'auto_exact',
        'explanation': {'en': 'Explanation'},
        'authoring': {
          'status': 'published',
          'authorId': 'sme_author',
          'reviewerId': 'sme_reviewer',
        },
        'payload': {
          'type': 'mcq_single',
          'stem': {'en': 'Question?'},
          'options': [
            {'id': 'a', 'content': {'en': 'Option A'}},
            {'id': 'b', 'content': {'en': 'Option B'}}
          ],
          'correctOptionId': 'a'
        }
      }));

      final success = await compileContent(src: tempSrc.path, out: outFilePath);
      expect(success, isTrue);

      final outFile = File(outFilePath);
      expect(await outFile.exists(), isTrue);

      final compiledData = jsonDecode(await outFile.readAsString()) as Map<String, dynamic>;
      expect(compiledData['exams'].length, equals(1));
      expect(compiledData['lessons'].length, equals(1));
      expect(compiledData['questions'].length, equals(1));

      expect(compiledData['exams'][0]['id'], equals('ex_test'));
      expect(compiledData['lessons'][0]['id'], equals('les_test'));
      expect(compiledData['questions'][0]['id'], equals('q_test'));
    });

    test('skips draft or in-review items and does not bundle them', () async {
      final lessonFile = File('${tempSrc.path}/lesson_draft.json');
      await lessonFile.writeAsString(jsonEncode({
        'contentType': 'lesson',
        'status': 'draft',
        'id': 'les_draft',
        'moduleId': 'mod_test',
        'title': {'en': 'Draft Lesson'},
      }));

      final success = await compileContent(src: tempSrc.path, out: outFilePath);
      expect(success, isTrue); // Returns true (clean compilation) but skipping warnings are logged

      final outFile = File(outFilePath);
      final compiledData = jsonDecode(await outFile.readAsString()) as Map<String, dynamic>;
      expect(compiledData['lessons'], isEmpty);
    });

    test('fails compilation if a published item is missing reviewer sign-off', () async {
      final lessonFile = File('${tempSrc.path}/lesson_no_reviewer.json');
      await lessonFile.writeAsString(jsonEncode({
        'contentType': 'lesson',
        'status': 'published',
        'author': 'sme_author',
        // 'reviewedBy' is missing
        'id': 'les_no_rev',
        'moduleId': 'mod_test',
        'title': {'en': 'No Reviewer'},
        'cards': [{'id': 'c1', 'kind': 'intro', 'blocks': [{'kind': 'text', 'md': {'en': 'B1'}}]}],
        'probeQuestionIds': ['q1']
      }));

      final success = await compileContent(src: tempSrc.path, out: outFilePath);
      expect(success, isFalse);
    });

    test('fails compilation if author is the reviewer (self-sign-off)', () async {
      final lessonFile = File('${tempSrc.path}/lesson_self_rev.json');
      await lessonFile.writeAsString(jsonEncode({
        'contentType': 'lesson',
        'status': 'published',
        'author': 'sme_author',
        'reviewedBy': 'sme_author', // self-sign-off
        'id': 'les_self_rev',
        'moduleId': 'mod_test',
        'title': {'en': 'Self Review'},
        'cards': [{'id': 'c1', 'kind': 'intro', 'blocks': [{'kind': 'text', 'md': {'en': 'B1'}}]}],
        'probeQuestionIds': ['q1']
      }));

      final success = await compileContent(src: tempSrc.path, out: outFilePath);
      expect(success, isFalse);
    });

    test('fails compilation if content validator fails (e.g. lesson has no cards)', () async {
      final lessonFile = File('${tempSrc.path}/lesson_no_cards.json');
      await lessonFile.writeAsString(jsonEncode({
        'contentType': 'lesson',
        'status': 'published',
        'author': 'sme_author',
        'reviewedBy': 'sme_reviewer',
        'id': 'les_no_cards',
        'moduleId': 'mod_test',
        'title': {'en': 'No Cards'},
        'cards': <dynamic>[], // Empty cards is a validation error
        'probeQuestionIds': ['q1']
      }));

      final success = await compileContent(src: tempSrc.path, out: outFilePath);
      expect(success, isFalse);
    });
  });
}
