import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:grading/grading.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../components/question_renderer.dart';
import '../components/block_renderer.dart';
import '../theme/tokens.dart';
import 'mock_result_screen.dart';

class MockPlayerScreen extends StatefulWidget {
  final MockBlueprint blueprint;
  final List<QuestionBase> questions;
  final List<Stimulus> stimuli;
  final String userId;
  final ContentStore contentStore;
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final Scheduler scheduler;
  final String examName;
  final ExamConfig examConfig;

  const MockPlayerScreen({
    super.key,
    required this.blueprint,
    required this.questions,
    required this.stimuli,
    required this.userId,
    required this.contentStore,
    required this.eventStore,
    required this.stateStore,
    required this.scheduler,
    required this.examName,
    required this.examConfig,
  });

  @override
  State<MockPlayerScreen> createState() => _MockPlayerScreenState();
}

class _MockPlayerScreenState extends State<MockPlayerScreen> {
  int _currentIndex = 0;
  final Map<String, Response> _responses = {};
  final Set<String> _flagged = {};

  Timer? _timer;
  late int _secondsRemaining;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    int durationMin = 120; // default
    if (widget.blueprint.timingFromPaper != null) {
      final paper = widget.examConfig.paper(widget.blueprint.timingFromPaper!);
      if (paper != null) {
        durationMin = paper.durationMin;
      }
    }
    _secondsRemaining = durationMin * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _autoSubmit() {
    if (_submitted) return;
    _submitted = true;
    _navigateToResults();
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (ctx) {
        final t = ctx.tokens;
        final unanswered = widget.questions.length - _responses.length;
        return AlertDialog(
          backgroundColor: t.bgSurface,
          title: Text(
            'Submit Mock Exam?',
            style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
          ),
          content: Text(
            unanswered > 0
                ? 'You have left $unanswered questions unanswered. Do you want to submit anyway?'
                : 'Are you ready to submit your mock exam and view the results?',
            style: AppTypography.body(t),
          ),
          actions: [
            CalmButton.secondary(
              text: 'Cancel',
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(width: 8),
            CalmButton.primary(
              text: 'Submit',
              onPressed: () {
                Navigator.of(ctx).pop();
                _timer?.cancel();
                _submitted = true;
                _navigateToResults();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToResults() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MockResultScreen(
          blueprint: widget.blueprint,
          questions: widget.questions,
          responses: _responses,
          userId: widget.userId,
          contentStore: widget.contentStore,
          eventStore: widget.eventStore,
          stateStore: widget.stateStore,
          scheduler: widget.scheduler,
          examName: widget.examName,
          examConfig: widget.examConfig,
        ),
      ),
    );
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < widget.questions.length) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: t.bgBase,
        body: const Center(child: Text('No questions assembled for this mock.')),
      );
    }

    final activeQuestion = widget.questions[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.questions.length - 1;
    final isAnswered = _responses.containsKey(activeQuestion.id);
    final isFlagged = _flagged.contains(activeQuestion.id);

    // Check if caselet (has stimulus)
    Stimulus? activeStimulus;
    if (activeQuestion.stimulusId != null) {
      activeStimulus = widget.stimuli
          .where((s) => s.id == activeQuestion.stimulusId)
          .firstOrNull;
    }

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.blueprint.name,
              style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              'Question ${_currentIndex + 1} of ${widget.questions.length}',
              style: AppTypography.caption(t),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _secondsRemaining < 300 ? t.danger.withOpacity(0.12) : t.accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(_secondsRemaining),
                style: AppTypography.heading(t).copyWith(
                  color: _secondsRemaining < 300 ? t.danger : t.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: TextButton(
                onPressed: _confirmSubmit,
                child: Text(
                  'Submit',
                  style: AppTypography.bodySm(t).copyWith(
                    color: t.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question selector bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: t.bgSurface,
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.questions.length,
                itemBuilder: (context, idx) {
                  final qId = widget.questions[idx].id;
                  final selected = idx == _currentIndex;
                  final answered = _responses.containsKey(qId);
                  final flagged = _flagged.contains(qId);

                  Color borderColor = t.border;
                  Color bgColor = Colors.transparent;
                  Color textColor = t.textSecondary;

                  if (selected) {
                    borderColor = t.accent;
                    textColor = t.accent;
                  } else if (flagged) {
                    borderColor = t.warning;
                    bgColor = t.warning.withOpacity(0.08);
                    textColor = t.warning;
                  } else if (answered) {
                    bgColor = t.accentSoft;
                    borderColor = t.accent;
                    textColor = t.accent;
                  }

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = idx),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor, width: selected ? 2.0 : 1.0),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${idx + 1}',
                            style: AppTypography.bodySm(t).copyWith(
                              color: textColor,
                              fontWeight: selected || answered || flagged ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (flagged)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(Icons.flag, size: 8, color: t.warning),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Question Workspace (Stimulus + Question)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (activeStimulus != null) ...[
                      CalmCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_outlined, color: t.accent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Caselet Scenario',
                                  style: AppTypography.heading(t).copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: t.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              activeStimulus.content.resolve('en'),
                              style: AppTypography.bodySm(t).copyWith(height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    QuestionRenderer(
                      key: ValueKey(activeQuestion.id),
                      question: activeQuestion,
                      showFeedback: false,
                      onAnswerChecked: (resp) {
                        _responses[activeQuestion.id] = resp;
                        setState(() {});
                      },
                      onContinue: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: t.bgSurface,
                border: Border(top: BorderSide(color: t.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: isFirst
                        ? const SizedBox.shrink()
                        : CalmButton.secondary(
                            text: 'Previous',
                            onPressed: _prevQuestion,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isFlagged,
                        activeColor: const Color(0xFFF57C00),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _flagged.add(activeQuestion.id);
                            } else {
                              _flagged.remove(activeQuestion.id);
                            }
                          });
                        },
                      ),
                      Text(
                        'Flag Question',
                        style: AppTypography.bodySm(t),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: isLast
                        ? CalmButton.primary(
                            text: 'Submit Exam',
                            onPressed: _confirmSubmit,
                          )
                        : CalmButton.primary(
                            text: 'Next',
                            onPressed: _nextQuestion,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
