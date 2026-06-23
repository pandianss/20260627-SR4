import 'dart:convert';
import 'dart:io';
import 'package:domain/domain.dart';

/// Validates a compiled content pack against the domain schema: parses every
/// item, runs the ContentValidator on lessons/questions, and checks
/// referential integrity (lesson -> module, lesson -> probe questions).
///
/// Usage: dart run bin/validate_pack.dart <pack.json>
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run bin/validate_pack.dart <pack.json>');
    exit(1);
  }
  final json =
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>;

  List<Map<String, dynamic>> list(String k) =>
      ((json[k] as List?) ?? const [])
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

  const v = ContentValidator(requiredLanguages: ['en']);
  var errors = 0;
  var warnings = 0;
  var shown = 0;
  void report(String where, ValidationResult r) {
    errors += r.errors.length;
    warnings += r.warnings.length;
    for (final e in r.errors) {
      if (shown++ < 40) print('[ERROR] $where: $e');
    }
  }

  final exams = list('exams').map(Exam.fromJson).toList();
  final papers = list('papers').map(Paper.fromJson).toList();
  final modules = list('modules').map(Module.fromJson).toList();
  final lessons = list('lessons').map(Lesson.fromJson).toList();
  final questions = list('questions').map(QuestionBase.fromJson).toList();
  final stimuli = list('stimuli').map(Stimulus.fromJson).toList();

  for (final l in lessons) {
    report('lesson ${l.id}', v.validateLesson(l));
  }
  for (final q in questions) {
    report('question ${q.id}', v.validateQuestion(q));
  }

  // Referential integrity.
  final moduleIds = modules.map((m) => m.id).toSet();
  final questionIds = questions.map((q) => q.id).toSet();
  for (final l in lessons) {
    if (!moduleIds.contains(l.moduleId)) {
      print('[ERROR] lesson ${l.id}: unknown moduleId "${l.moduleId}"');
      errors++;
    }
    for (final pid in l.probeQuestionIds) {
      if (!questionIds.contains(pid)) {
        print('[ERROR] lesson ${l.id}: missing probe question "$pid"');
        errors++;
      }
    }
  }

  print('--- exams=${exams.length} papers=${papers.length} '
      'modules=${modules.length} lessons=${lessons.length} '
      'questions=${questions.length} stimuli=${stimuli.length}');
  print('--- errors=$errors warnings=$warnings');
  exit(errors == 0 ? 0 : 1);
}
