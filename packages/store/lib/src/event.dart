import 'package:grading/grading.dart';
import 'package:srs/srs.dart';

/// Base class for all event-sourced action log entries (epic E4.2).
sealed class SrsEvent {
  final String clientUlid;
  final String userId;
  final DateTime timestamp;
  final String examContext;

  const SrsEvent({
    required this.clientUlid,
    required this.userId,
    required this.timestamp,
    required this.examContext,
  });

  String get type;
  Map<String, dynamic> toJson();

  factory SrsEvent.fromJson(Map<String, dynamic> j) {
    final t = j['type'] as String;
    return switch (t) {
      'lesson_viewed' => LessonViewedEvent.fromJson(j),
      'card_reviewed' => CardReviewedEvent.fromJson(j),
      'question_answered' => QuestionAnsweredEvent.fromJson(j),
      'mock_submitted' => MockSubmittedEvent.fromJson(j),
      'feedback_submitted' => FeedbackSubmittedEvent.fromJson(j),
      _ => throw FormatException('Unknown event type: $t'),
    };
  }
}

class LessonViewedEvent extends SrsEvent {
  final String lessonId;

  const LessonViewedEvent({
    required super.clientUlid,
    required super.userId,
    required super.timestamp,
    required super.examContext,
    required this.lessonId,
  });

  @override
  String get type => 'lesson_viewed';

  factory LessonViewedEvent.fromJson(Map<String, dynamic> j) =>
      LessonViewedEvent(
        clientUlid: j['clientUlid'] as String,
        userId: j['userId'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        examContext: j['examContext'] as String,
        lessonId: j['lessonId'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'clientUlid': clientUlid,
        'userId': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'examContext': examContext,
        'lessonId': lessonId,
      };
}

class CardReviewedEvent extends SrsEvent {
  final String itemId;
  final Rating rating;

  const CardReviewedEvent({
    required super.clientUlid,
    required super.userId,
    required super.timestamp,
    required super.examContext,
    required this.itemId,
    required this.rating,
  });

  @override
  String get type => 'card_reviewed';

  factory CardReviewedEvent.fromJson(Map<String, dynamic> j) =>
      CardReviewedEvent(
        clientUlid: j['clientUlid'] as String,
        userId: j['userId'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        examContext: j['examContext'] as String,
        itemId: j['itemId'] as String,
        rating: Rating.values.byName(j['rating'] as String),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'clientUlid': clientUlid,
        'userId': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'examContext': examContext,
        'itemId': itemId,
        'rating': rating.name,
      };
}

class QuestionAnsweredEvent extends SrsEvent {
  final String questionId;
  final Response response;
  final Correctness correctness;
  final double marksAwarded;

  const QuestionAnsweredEvent({
    required super.clientUlid,
    required super.userId,
    required super.timestamp,
    required super.examContext,
    required this.questionId,
    required this.response,
    required this.correctness,
    required this.marksAwarded,
  });

  @override
  String get type => 'question_answered';

  factory QuestionAnsweredEvent.fromJson(Map<String, dynamic> j) =>
      QuestionAnsweredEvent(
        clientUlid: j['clientUlid'] as String,
        userId: j['userId'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        examContext: j['examContext'] as String,
        questionId: j['questionId'] as String,
        response: Response.fromJson((j['response'] as Map).cast<String, dynamic>()),
        correctness: Correctness.values.byName(j['correctness'] as String),
        marksAwarded: (j['marksAwarded'] as num).toDouble(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'clientUlid': clientUlid,
        'userId': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'examContext': examContext,
        'questionId': questionId,
        'response': response.toJson(),
        'correctness': correctness.name,
        'marksAwarded': marksAwarded,
      };
}

class MockAnswerSummary {
  final String questionId;
  final Correctness correctness;
  final double score;

  const MockAnswerSummary({
    required this.questionId,
    required this.correctness,
    required this.score,
  });

  factory MockAnswerSummary.fromJson(Map<String, dynamic> j) =>
      MockAnswerSummary(
        questionId: j['questionId'] as String,
        correctness: Correctness.values.byName(j['correctness'] as String),
        score: (j['score'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'correctness': correctness.name,
        'score': score,
      };
}

class MockSubmittedEvent extends SrsEvent {
  final String mockResultId;
  final String paperId;
  final double score;
  final double maxScore;
  final bool passed;
  final List<MockAnswerSummary> answers;

  const MockSubmittedEvent({
    required super.clientUlid,
    required super.userId,
    required super.timestamp,
    required super.examContext,
    required this.mockResultId,
    required this.paperId,
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.answers,
  });

  @override
  String get type => 'mock_submitted';

  factory MockSubmittedEvent.fromJson(Map<String, dynamic> j) =>
      MockSubmittedEvent(
        clientUlid: j['clientUlid'] as String,
        userId: j['userId'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        examContext: j['examContext'] as String,
        mockResultId: j['mockResultId'] as String,
        paperId: j['paperId'] as String,
        score: (j['score'] as num).toDouble(),
        maxScore: (j['maxScore'] as num).toDouble(),
        passed: j['passed'] as bool,
        answers: (j['answers'] as List)
            .map((e) => MockAnswerSummary.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'clientUlid': clientUlid,
        'userId': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'examContext': examContext,
        'mockResultId': mockResultId,
        'paperId': paperId,
        'score': score,
        'maxScore': maxScore,
        'passed': passed,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

class FeedbackSubmittedEvent extends SrsEvent {
  final int rating;
  final String comments;

  const FeedbackSubmittedEvent({
    required super.clientUlid,
    required super.userId,
    required super.timestamp,
    required super.examContext,
    required this.rating,
    required this.comments,
  });

  @override
  String get type => 'feedback_submitted';

  factory FeedbackSubmittedEvent.fromJson(Map<String, dynamic> j) =>
      FeedbackSubmittedEvent(
        clientUlid: j['clientUlid'] as String,
        userId: j['userId'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        examContext: j['examContext'] as String,
        rating: (j['rating'] as num).toInt(),
        comments: j['comments'] as String? ?? '',
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'clientUlid': clientUlid,
        'userId': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'examContext': examContext,
        'rating': rating,
        'comments': comments,
      };
}
