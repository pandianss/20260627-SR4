import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:grading/grading.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../components/block_renderer.dart';
import '../components/question_renderer.dart';
import '../components/caselet_renderer.dart';
import '../theme/tokens.dart';
import '../services/audio_narration_service.dart';
import '../components/flag_content_dialog.dart';
import '../app_scope.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;
  final List<QuestionBase> questions;
  final List<Stimulus> stimuli;
  final String userId;
  final Function(List<SrsEvent> events) onComplete;

  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    required this.questions,
    required this.stimuli,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  int _currentCardIndex = 0;
  bool _isPlayingQuestions = false;
  int _currentQuestionIndex = 0;

  final List<SrsEvent> _generatedEvents = [];

  // Pager controller
  late final PageController _cardPageController;
  late final AudioNarrationService _narrationService;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController();
    _narrationService = AudioNarrationService();
    _narrationService.addListener(_onNarrationUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFlagHighlight());
  }

  Future<void> _checkFlagHighlight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_flag_tip') ?? false;
      if (!hasSeen) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.outlined_flag, color: context.tokens.onInk, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Content error? Tap the flag icon in the top right to report it.',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        await prefs.setBool('has_seen_flag_tip', true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _narrationService.removeListener(_onNarrationUpdate);
    _narrationService.stop();
    _narrationService.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  void _onNarrationUpdate() {
    if (_narrationService.isPlaying && _narrationService.currentIndex != _currentCardIndex) {
      setState(() {
        _currentCardIndex = _narrationService.currentIndex;
      });
      if (_cardPageController.hasClients) {
        _cardPageController.animateToPage(
          _currentCardIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  List<String> _extractLessonTexts() {
    final List<String> result = [];
    for (final card in widget.lesson.cards) {
      final buffer = StringBuffer();
      for (final block in card.blocks) {
        if (block is TextBlock) {
          buffer.write(block.md.resolve('en'));
          buffer.write(' ');
        }
      }
      result.add(buffer.toString().trim());
    }
    return result;
  }

  void _finishCardDeck() {
    setState(() {
      _isPlayingQuestions = true;
      _currentQuestionIndex = 0;
    });
  }

  void _recordQuestionAnswer(String questionId, Response response, Correctness correctness, double marks) {
    // Generate a client ULID for the sync protocol
    final clientUlid = 'ulid_ans_${questionId}_${DateTime.now().millisecondsSinceEpoch}';

    _generatedEvents.add(QuestionAnsweredEvent(
      clientUlid: clientUlid,
      userId: widget.userId,
      timestamp: DateTime.now(),
      examContext: widget.lesson.moduleId, // usemoduleId as contextual exam-scoping
      questionId: questionId,
      response: response,
      correctness: correctness,
      marksAwarded: marks,
    ));
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < widget.questions.length) {
      setState(() {
        _currentQuestionIndex += 1;
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    _narrationService.stop();
    // Generate lesson viewed event
    final viewUlid = 'ulid_view_${widget.lesson.id}_${DateTime.now().millisecondsSinceEpoch}';
    _generatedEvents.add(LessonViewedEvent(
      clientUlid: viewUlid,
      userId: widget.userId,
      timestamp: DateTime.now(),
      examContext: widget.lesson.moduleId,
      lessonId: widget.lesson.id,
    ));

    widget.onComplete(_generatedEvents);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final totalCards = widget.lesson.cards.length;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgSurface,
        elevation: 0,
        title: Text(
          widget.lesson.title.resolve('en'),
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
        leading: Semantics(
          label: 'Close Lesson',
          container: true,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _narrationService.stop();
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          if (!_isPlayingQuestions)
            Semantics(
              label: 'Toggle Audio Narration',
              button: true,
              container: true,
              child: IconButton(
                icon: Icon(
                  _narrationService.isPlaying && !_narrationService.isPaused
                      ? Icons.volume_up
                      : Icons.volume_mute,
                  color: _narrationService.isPlaying ? t.accent : t.textSecondary,
                ),
                tooltip: 'Audio Narration',
                onPressed: () {
                  if (_narrationService.isPlaying) {
                    if (_narrationService.isPaused) {
                      _narrationService.resume();
                    } else {
                      _narrationService.pause();
                    }
                  } else {
                    final texts = _extractLessonTexts();
                    _narrationService.play(
                      texts,
                      onProgress: (idx) {},
                      onDone: () {},
                    );
                  }
                  setState(() {});
                },
              ),
            ),
          Semantics(
            label: 'Report Issue',
            button: true,
            container: true,
            child: IconButton(
              icon: Icon(Icons.flag_outlined, color: t.textSecondary),
              tooltip: 'Report an issue with this content',
              onPressed: () {
                final activeId = _isPlayingQuestions
                    ? widget.questions[_currentQuestionIndex].id
                    : widget.lesson.cards[_currentCardIndex].id;
                final activeType = _isPlayingQuestions ? 'question' : 'card';
                showFlagContentDialog(
                  context: context,
                  contentId: activeId,
                  contentType: activeType,
                  userId: widget.userId,
                  examContext: widget.lesson.moduleId,
                  onFlagSubmitted: ({
                    required userId,
                    required examContext,
                    required contentId,
                    required contentType,
                    required reason,
                  }) async {
                    await AppScope.of(context).repository.flagContent(
                          userId: userId,
                          examContext: examContext,
                          contentId: contentId,
                          contentType: contentType,
                          reason: reason,
                        );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _isPlayingQuestions
                    ? 'Check ${_currentQuestionIndex + 1}/${widget.questions.length}'
                    : 'Card ${_currentCardIndex + 1}/$totalCards',
                style: AppTypography.caption(t),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Content Card (either Deck Card or Question)
              Expanded(
                child: _isPlayingQuestions
                    ? _buildQuestionStep(t)
                    : _buildCardStep(t),
              ),
              if (!_isPlayingQuestions && _narrationService.isPlaying) ...[
                const SizedBox(height: 16),
                _buildNarrationOverlay(t),
              ],
              const SizedBox(height: 16),

              // 2. Navigation Actions for Card Deck
              if (!_isPlayingQuestions) _buildCardDeckNavigation(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrationOverlay(AppTokens t) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.hearing_outlined, color: t.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Narration Playing',
                style: AppTypography.caption(t).copyWith(color: t.accent, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _narrationService.stop();
                  setState(() {});
                },
                child: Icon(Icons.stop_circle_outlined, color: t.accent, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _narrationService.currentText,
            style: AppTypography.bodySm(t).copyWith(fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCardStep(AppTokens t) {
    return PageView.builder(
      controller: _cardPageController,
      onPageChanged: (idx) {
        setState(() => _currentCardIndex = idx);
        if (_narrationService.isPlaying && _narrationService.currentIndex != idx) {
          _narrationService.stop();
        }
      },
      itemCount: widget.lesson.cards.length,
      itemBuilder: (context, index) {
        final card = widget.lesson.cards[index];
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      container: true,
                      label: 'Concept card ${index + 1} of ${widget.lesson.cards.length}',
                      child: LessonCardLayout(
                        card: card,
                        cardIndex: index,
                        totalCards: widget.lesson.cards.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardDeckNavigation(AppTokens t) {
    final total = widget.lesson.cards.length;
    final isLast = _currentCardIndex == total - 1;

    return Row(
      children: [
        if (_currentCardIndex > 0)
          Expanded(
            child: CalmButton.secondary(
              text: 'Previous',
              onPressed: () {
                _cardPageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          )
        else
          const Spacer(),
        if (_currentCardIndex > 0) const SizedBox(width: 16),
        Expanded(
          child: CalmButton.primary(
            text: isLast ? 'Start Practice' : 'Next Card',
            onPressed: () {
              if (isLast) {
                _narrationService.stop();
                _finishCardDeck();
              } else {
                _cardPageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionStep(AppTokens t) {
    if (widget.questions.isEmpty) {
      _finishLesson();
      return const SizedBox.shrink();
    }

    final question = widget.questions[_currentQuestionIndex];

    // If the question requires a stimulus (caselet DI set)
    if (question.stimulusId != null) {
      final stimulus = widget.stimuli
          .where((s) => s.id == question.stimulusId)
          .firstOrNull;

      if (stimulus != null) {
        // Collect all child questions that share this stimulus
        final childQuestions = widget.questions
            .where((q) => q.stimulusId == stimulus.id)
            .toList();

        // Check if we are at the first child of the caselet
        final caseletIndex = childQuestions.indexWhere((q) => q.id == question.id);

        return SingleChildScrollView(
          child: CaseletRenderer(
            key: ValueKey(stimulus.id),
            stimulus: stimulus,
            childQuestions: childQuestions.sublist(caseletIndex),
            onQuestionAnswered: (qid, response) {
              _recordQuestionAnswer(qid, response, Correctness.correct, 1.0);
            },
            onComplete: () {
              // Skip current index past remaining caselet child questions
              final remainingCount = childQuestions.length - caseletIndex;
              setState(() {
                _currentQuestionIndex += remainingCount;
              });
              if (_currentQuestionIndex < widget.questions.length) {
                // keep playing
              } else {
                _finishLesson();
              }
            },
          ),
        );
      }
    }

    // Default standalone question
    return SingleChildScrollView(
      child: QuestionRenderer(
        key: ValueKey(question.id),
        question: question,
        onAnswerChecked: (response) {
          _recordQuestionAnswer(question.id, response, Correctness.correct, 1.0);
        },
        onContinue: _nextQuestion,
      ),
    );
  }
}
