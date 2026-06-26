import 'package:flutter/material.dart' hide Card;
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:grading/grading.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../components/progress_ring.dart';
import '../theme/tokens.dart';

class MockResultScreen extends StatefulWidget {
  final MockBlueprint blueprint;
  final List<QuestionBase> questions;
  final Map<String, Response> responses;
  final String userId;
  final ContentStore contentStore;
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final Scheduler scheduler;
  final String examName;
  final ExamConfig examConfig;

  const MockResultScreen({
    super.key,
    required this.blueprint,
    required this.questions,
    required this.responses,
    required this.userId,
    required this.contentStore,
    required this.eventStore,
    required this.stateStore,
    required this.scheduler,
    required this.examName,
    required this.examConfig,
  });

  @override
  State<MockResultScreen> createState() => _MockResultScreenState();
}

class _MockResultScreenState extends State<MockResultScreen> {
  bool _calculating = true;
  late double _totalScore;
  late double _maxScore;
  late PassOutcome _passOutcome;
  late Map<String, double> _weaknessMap;
  late Map<String, GradeResult> _questionGrades;

  @override
  void initState() {
    super.initState();
    _gradeMock();
  }

  Future<void> _gradeMock() async {
    _totalScore = 0;
    _maxScore = 0;
    _questionGrades = {};

    final grader = const Grader();
    for (final q in widget.questions) {
      final response = widget.responses[q.id];
      // In P0 / JAIIB config, fall back to 1.0 mark per question / 0 negative marks
      final rule = const MarkingRule(marks: 1.0, negativeMarks: 0.0);
      final raw = grader.grade(q, response);
      final grade = applyMarking(raw, rule, answered: response != null);
      _questionGrades[q.id] = grade;
      _totalScore += grade.score;
      _maxScore += grade.maxScore;
    }

    final paperCode = widget.blueprint.timingFromPaper ?? 'PPB';
    final compScore = ComponentScore(code: paperCode, scored: _totalScore, max: _maxScore);
    _passOutcome = evaluatePass([compScore], widget.examConfig.passRule);

    // Compute Weakness Map
    final Map<String, List<bool>> topicResults = {};
    for (final q in widget.questions) {
      final grade = _questionGrades[q.id];
      final isCorrect = grade?.correctness == Correctness.correct;
      for (final tag in q.topicTags) {
        topicResults.putIfAbsent(tag, () => []).add(isCorrect);
      }
    }

    _weaknessMap = {};
    topicResults.forEach((tag, results) {
      final correctCount = results.where((r) => r).length;
      _weaknessMap[tag] = results.isNotEmpty ? correctCount / results.length : 0.0;
    });

    // 1. Submit MockSubmittedEvent
    final answersSummary = _questionGrades.entries.map((entry) {
      return MockAnswerSummary(
        questionId: entry.key,
        correctness: entry.value.correctness,
        score: entry.value.score,
      );
    }).toList();

    final now = DateTime.now();
    final clientUlid = 'ulid_mock_${widget.blueprint.id}_${now.millisecondsSinceEpoch}';
    final event = MockSubmittedEvent(
      clientUlid: clientUlid,
      userId: widget.userId,
      timestamp: now,
      examContext: widget.examName,
      mockResultId: 'res_${widget.blueprint.id}_${now.millisecondsSinceEpoch}',
      paperId: paperCode,
      score: _totalScore,
      maxScore: _maxScore,
      passed: _passOutcome.passed,
      answers: answersSummary,
    );

    await widget.eventStore.appendEvent(event);

    // 2. Trigger FSRS projection for wrong/unanswered questions to mark them as high-priority lapses
    for (final q in widget.questions) {
      final itemEvents = await widget.eventStore.getEventsForItem(widget.userId, q.id);
      final nextState = projectSrsState(
        userId: widget.userId,
        itemId: q.id,
        events: itemEvents,
        scheduler: widget.scheduler,
        examContext: widget.examName,
      );
      if (nextState != null) {
        await widget.stateStore.saveState(nextState);
      }
    }

    if (mounted) {
      setState(() {
        _calculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    if (_calculating) {
      return Scaffold(
        backgroundColor: t.bgBase,
        body: Center(
          child: CircularProgressIndicator(color: t.accent),
        ),
      );
    }

    final scorePercent = _maxScore > 0 ? (_totalScore / _maxScore) : 0.0;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Mock Analysis',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Card
              CalmCard(
                child: Column(
                  children: [
                    Text(
                      widget.blueprint.name,
                      style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    CalmProgressRing(progress: scorePercent, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      'Score: ${_totalScore.toStringAsFixed(1)} / ${_maxScore.toStringAsFixed(0)}',
                      style: AppTypography.title(t).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(scorePercent * 100).toStringAsFixed(1)}%',
                      style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _passOutcome.passed ? t.accentSoft : t.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _passOutcome.passed ? 'PASSED' : 'FAILED',
                        style: AppTypography.body(t).copyWith(
                          color: _passOutcome.passed ? t.accent : t.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _passOutcome.reason,
                      style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weakness Map Section
              Text(
                'Topic Weakness Analysis',
                style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              if (_weaknessMap.isEmpty)
                CalmCard(
                  child: Text(
                    'No topics tagged in this mock test.',
                    style: AppTypography.bodySm(t),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._weaknessMap.entries.map((entry) {
                  final topic = entry.key.toUpperCase();
                  final accuracy = entry.value;
                  final accuracyPercent = (accuracy * 100).toStringAsFixed(0);

                  Color barColor = t.accent;
                  Color softColor = t.accentSoft;
                  String label = 'Strong';

                  if (accuracy < 0.4) {
                    barColor = t.danger;
                    softColor = t.danger.withOpacity(0.12);
                    label = 'Critical Weakness';
                  } else if (accuracy < 0.7) {
                    barColor = const Color(0xFFF57C00); // Amber
                    softColor = const Color(0xFFFFF3E0);
                    label = 'Warning';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CalmCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                topic,
                                style: AppTypography.body(t).copyWith(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: softColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$label ($accuracyPercent%)',
                                  style: AppTypography.micro(t).copyWith(
                                    color: barColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: accuracy,
                              backgroundColor: t.border,
                              color: barColor,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 32),
              _buildAnswerReview(t),
              const SizedBox(height: 32),
              CalmButton.primary(
                text: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Per-question answer key: the correct option, the learner's choice, and the
  /// explanation for every question in the mock.
  Widget _buildAnswerReview(AppTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Answer Review',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...widget.questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value;
          final payload = q.payload;
          if (payload is! McqSingle) return const SizedBox.shrink();

          final grade = _questionGrades[q.id];
          final isCorrect = grade?.correctness == Correctness.correct;
          final response = widget.responses[q.id];
          final userOptionId = response is McqResponse ? response.optionId : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CalmCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        userOptionId == null
                            ? Icons.remove_circle_outline
                            : (isCorrect ? Icons.check_circle : Icons.cancel),
                        size: 18,
                        color: userOptionId == null
                            ? t.textTertiary
                            : (isCorrect ? t.accent : t.danger),
                      ),
                      const SizedBox(width: 6),
                      Text('Q${idx + 1}',
                          style: AppTypography.caption(t)
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(
                        userOptionId == null
                            ? 'Not answered'
                            : (isCorrect ? 'Correct' : 'Incorrect'),
                        style: AppTypography.caption(t).copyWith(
                          color: userOptionId == null
                              ? t.textTertiary
                              : (isCorrect ? t.accentText : t.danger),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(payload.stem.resolve('en'),
                      style: AppTypography.body(t)
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  ...payload.options.map((o) {
                    final isAnswer = o.id == payload.correctOptionId;
                    final isUserPick = o.id == userOptionId;
                    Color bg = Colors.transparent;
                    Color fg = t.textSecondary;
                    IconData? icon;
                    if (isAnswer) {
                      bg = t.accentSoft;
                      fg = t.accentText;
                      icon = Icons.check;
                    } else if (isUserPick) {
                      bg = t.danger.withOpacity(0.10);
                      fg = t.danger;
                      icon = Icons.close;
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 14, color: fg),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              o.content.resolve('en'),
                              style: AppTypography.bodySm(t).copyWith(
                                color: (isAnswer || isUserPick)
                                    ? fg
                                    : t.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.bgBase,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: t.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q.explanation.resolve('en'),
                            style: AppTypography.caption(t)
                                .copyWith(color: t.textSecondary, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
