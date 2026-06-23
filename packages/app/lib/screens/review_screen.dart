import 'package:flutter/material.dart' hide Card;
import 'package:domain/domain.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../components/rating_buttons.dart';
import '../components/block_renderer.dart';
import '../theme/tokens.dart';

class ReviewScreen extends StatefulWidget {
  final String userId;
  final String examContext;
  final ContentStore contentStore;
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final Scheduler scheduler;

  const ReviewScreen({
    super.key,
    required this.userId,
    required this.examContext,
    required this.contentStore,
    required this.eventStore,
    required this.stateStore,
    required this.scheduler,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  List<SrsState> _dueStates = [];
  final Map<String, LearnableItem> _learnableItems = {};
  final Map<String, Card> _cards = {};

  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _loadDueQueue();
  }

  Future<void> _loadDueQueue() async {
    setState(() => _isLoading = true);

    // 1. Fetch all states and create a mock map of learnable items for lookup
    final allStates = await widget.stateStore.getStatesForExam(widget.userId, widget.examContext);

    // Mock query learnable items from content base
    // In our mock, let's load all cards that are srsEligible and register them
    final exam = await widget.contentStore.getExamByCode(widget.examContext) ?? 
                 await widget.contentStore.getExam('ex_ppb');

    if (exam != null) {
      final papers = await widget.contentStore.getPapersByExam(exam.code);
      for (final paper in papers) {
        final modules = await widget.contentStore.getModulesByPaper(paper.id);
        for (final mod in modules) {
          final lessons = await widget.contentStore.getLessonsByModule(mod.id);
          for (final lesson in lessons) {
            // Register card items
            for (final card in lesson.cards) {
              if (card.srsEligible) {
                _cards[card.id] = card;
                _learnableItems[card.id] = LearnableItem(
                  id: card.id,
                  kind: LearnableItemKind.card,
                  refId: card.id,
                  topicTags: mod.topicTags,
                  examContexts: [exam.code],
                );
              }
            }
          }
        }
      }
    }

    // 2. Build FSRS due queue
    final dueQueue = buildDueQueue(
      states: allStates,
      items: _learnableItems,
      now: DateTime.now(),
      budget: 15,
    );

    setState(() {
      _dueStates = dueQueue;
      _currentIndex = 0;
      _isFlipped = false;
      _isLoading = false;
    });
  }

  Future<void> _handleRating(Rating rating) async {
    final currentState = _dueStates[_currentIndex];
    final now = DateTime.now();

    // 1. Update state through scheduler
    final nextState = widget.scheduler.review(currentState, rating, now);

    // 2. Save state to store
    await widget.stateStore.saveState(nextState);

    // 3. Append CardReviewedEvent to event log
    final clientUlid = 'ulid_rev_${currentState.itemId}_${now.millisecondsSinceEpoch}';
    await widget.eventStore.appendEvent(CardReviewedEvent(
      clientUlid: clientUlid,
      userId: widget.userId,
      timestamp: now,
      examContext: widget.examContext,
      itemId: currentState.itemId,
      rating: rating,
    ));

    // 4. Advance to next card
    if (_currentIndex + 1 < _dueStates.length) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
      });
    } else {
      // Reload queue when finished
      _loadDueQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: t.bgBase,
        body: Center(
          child: CircularProgressIndicator(color: t.accent),
        ),
      );
    }

    if (_dueStates.isEmpty) {
      return Scaffold(
        backgroundColor: t.bgBase,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: t.accent,
                    size: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'All caught up!',
                    style: AppTypography.title(t).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No spaced reviews are due today. Come back tomorrow!',
                    style: AppTypography.bodySm(t),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CalmButton.secondary(
                    text: 'Refresh Queue',
                    onPressed: _loadDueQueue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentState = _dueStates[_currentIndex];
    final cardId = currentState.itemId;
    final card = _cards[cardId];

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgSurface,
        elevation: 0,
        title: Text(
          'Recall Practice',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Review ${_currentIndex + 1}/${_dueStates.length}',
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
              // Double-sided Card flip container
              Expanded(
                child: SingleChildScrollView(
                  child: CalmCard(
                    child: AnimatedCrossFade(
                      firstChild: _buildFrontCard(t, cardId),
                      secondChild: _buildBackCard(t, card),
                      crossFadeState: _isFlipped
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rating Buttons HUD
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isFlipped
                    ? CalmRatingButtons(
                        key: ValueKey(_currentIndex),
                        onRatingSelected: _handleRating,
                      )
                    : CalmButton.primary(
                        key: const ValueKey('reveal_btn'),
                        text: 'Reveal Answer',
                        onPressed: () => setState(() => _isFlipped = true),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(AppTokens t, String cardId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_outlined, color: t.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Active Recall Prompt',
              style: AppTypography.heading(t).copyWith(
                fontWeight: FontWeight.w500,
                color: t.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Can you recall the key details regarding this concept?',
          style: AppTypography.body(t).copyWith(height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Item ID: $cardId',
          style: AppTypography.caption(t),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackCard(AppTokens t, Card? card) {
    if (card == null) {
      return Center(
        child: Text('Card details missing', style: AppTypography.body(t)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: t.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Concept Details',
              style: AppTypography.heading(t).copyWith(
                fontWeight: FontWeight.w500,
                color: t.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...card.blocks.map((b) => ContentBlockRenderer(block: b)).toList(),
      ],
    );
  }
}
