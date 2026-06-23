import 'dart:convert';
import 'dart:io';
import 'package:domain/domain.dart';

void main(List<String> args) async {
  String srcPath = '';
  String outPath = '';
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--src' && i + 1 < args.length) {
      srcPath = args[i + 1];
    } else if (args[i] == '--out' && i + 1 < args.length) {
      outPath = args[i + 1];
    }
  }

  if (srcPath.isEmpty || outPath.isEmpty) {
    print('Usage: dart run compile_content.dart --src <source_dir> --out <output_file>');
    exit(1);
  }

  final success = await compileContent(src: srcPath, out: outPath);
  exit(success ? 0 : 1);
}

Future<bool> compileContent({required String src, required String out}) async {
  final dir = Directory(src);
  if (!await dir.exists()) {
    print('Source directory does not exist: $src');
    return false;
  }

  final List<Exam> exams = [];
  final List<Paper> papers = [];
  final List<Module> modules = [];
  final List<Lesson> lessons = [];
  final List<QuestionBase> questions = [];
  final List<Asset> assets = [];
  final List<Stimulus> stimuli = [];

  bool hasErrors = false;

  final validator = const ContentValidator(requiredLanguages: ['en']);

  final List<FileSystemEntity> entities = await dir.list(recursive: true).toList();
  // Sort files for deterministic output ordering
  entities.sort((a, b) => a.path.compareTo(b.path));

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.json')) {
      try {
        final content = await entity.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final contentType = json['contentType'] as String?;

        if (contentType == null) {
          print('[ERROR] File ${entity.path} is missing "contentType"');
          hasErrors = true;
          continue;
        }

        // Check review workflow status
        bool isPublished = false;
        String? author;
        String? reviewer;

        if (contentType == 'question') {
          final authoring = json['authoring'] as Map?;
          if (authoring != null) {
            final statusStr = authoring['status'] as String?;
            isPublished = (statusStr == 'published');
            author = authoring['authorId'] as String?;
            reviewer = authoring['reviewerId'] as String?;
          }
        } else {
          final statusStr = json['status'] as String?;
          isPublished = (statusStr == 'published');
          author = json['author'] as String?;
          reviewer = json['reviewedBy'] as String?;
        }

        // Structural metadata (exam, paper, module) does not enforce reviewer signoff
        final isStructural = ['exam', 'paper', 'module'].contains(contentType);

        if (!isStructural && !isPublished) {
          print('[WARNING] Skipping ${contentType} "${json['id'] ?? entity.path}" (Status: ${json['status'] ?? 'draft'})');
          continue;
        }

        if (!isStructural) {
          if (reviewer == null || reviewer.isEmpty) {
            print('[ERROR] "${json['id'] ?? entity.path}" is published but lacks second-reviewer sign-off ("reviewedBy"/"reviewerId")');
            hasErrors = true;
            continue;
          }
          if (author == reviewer) {
            print('[ERROR] "${json['id'] ?? entity.path}" cannot be signed off by its author ($author)');
            hasErrors = true;
            continue;
          }
        }

        // Parse and validate based on contentType
        switch (contentType) {
          case 'exam':
            exams.add(Exam.fromJson(json));
            break;
          case 'paper':
            papers.add(Paper.fromJson(json));
            break;
          case 'module':
            modules.add(Module.fromJson(json));
            break;
          case 'lesson':
            final lesson = Lesson.fromJson(json);
            final valResult = validator.validateLesson(lesson);
            if (!valResult.publishable) {
              print('[ERROR] Lesson validation failed for "${lesson.id}":');
              for (final issue in valResult.issues) {
                print('  - $issue');
              }
              hasErrors = true;
            } else {
              lessons.add(lesson);
            }
            break;
          case 'question':
            final question = QuestionBase.fromJson(json);
            final valResult = validator.validateQuestion(question);
            if (!valResult.publishable) {
              print('[ERROR] Question validation failed for "${question.id}":');
              for (final issue in valResult.issues) {
                print('  - $issue');
              }
              hasErrors = true;
            } else {
              questions.add(question);
            }
            break;
          case 'stimulus':
            stimuli.add(Stimulus.fromJson(json));
            break;
          case 'asset':
            assets.add(Asset.fromJson(json));
            break;
          default:
            print('[ERROR] Unknown contentType "$contentType" in ${entity.path}');
            hasErrors = true;
        }
      } catch (e, stack) {
        print('[ERROR] Failed to parse ${entity.path}: $e');
        print(stack);
        hasErrors = true;
      }
    }
  }

  if (hasErrors) {
    print('Compilation aborted due to validation errors.');
    return false;
  }

  final compiledPack = {
    'exams': exams.map((e) => e.toJson()).toList(),
    'papers': papers.map((e) => e.toJson()).toList(),
    'modules': modules.map((e) => e.toJson()).toList(),
    'lessons': lessons.map((e) => e.toJson()).toList(),
    'questions': questions.map((e) => e.toJson()).toList(),
    'assets': assets.map((e) => e.toJson()).toList(),
    'stimuli': stimuli.map((e) => e.toJson()).toList(),
  };

  try {
    final outFile = File(out);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(compiledPack));
    print('Successfully compiled content pack to $out');
    print('Summary:');
    print('  - Exams: ${exams.length}');
    print('  - Papers: ${papers.length}');
    print('  - Modules: ${modules.length}');
    print('  - Lessons: ${lessons.length}');
    print('  - Questions: ${questions.length}');
    print('  - Stimuli: ${stimuli.length}');
    print('  - Assets: ${assets.length}');
    return true;
  } catch (e) {
    print('[ERROR] Failed to write output file: $e');
    return false;
  }
}
