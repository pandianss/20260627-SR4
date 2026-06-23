import 'package:flutter/material.dart' hide Card;
import 'package:domain/domain.dart';
import 'package:srs/srs.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../components/rating_buttons.dart';
import '../components/block_renderer.dart';
import '../theme/tokens.dart';
import '../data/learning_repository.dart';
import '../app_scope.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  List<SrsState> _dueStates = [];
  final Map<String, Card> _cards = {};

  int _currentIndex = 0;
  bool _isFlipped = false;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDueQueue();
    });
  }

  Future<void> _loadDueQueue() async {
    setState(() => _isLoading = true);
    final result = await _repo.loadDueReviews(_scope.userId, _scope.examName,
        budget: 15);
    if (!mounted) return;
    setState(() {
      _dueStates = result.states;
      _cards
        ..clear()
        ..addAll(result.cards);
      _currentIndex = 0;
      _isFlipped = false;
      _isLoading = false;
    });
  }

  Future<void> _handleRating(Rating rating) async {
    final currentState = _dueStates[_currentIndex];
    await _repo.applyReview(
        _scope.userId, _scope.examName, currentState, rating);

    // Advance to next card
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
