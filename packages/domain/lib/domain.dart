/// Shared domain model for the IIBF micro-learning platform (epic E1).
///
/// Content schema (`Exam -> Paper -> Module -> Lesson -> Card`), the polymorphic
/// question-type union, localized strings, and the publish-gate validator.
/// Pure Dart, no Flutter dependency, so the same model is used by the mobile
/// app and the backend.
library;

export 'src/localized.dart';
export 'src/content.dart';
export 'src/question.dart';
export 'src/exam_config.dart';
export 'src/validation.dart';
export 'src/assembly.dart';
