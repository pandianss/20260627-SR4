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
import 'paywall_screen.dart';

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
  int _reviewsCompletedThisSession = 0;
  Listenable? _revision;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDueQueue();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload the due deck live when another device's progress merges in.
    final rev = AppScope.of(context).syncRevision;
    if (!identical(rev, _revision)) {
      _revision?.removeListener(_onRemoteSync);
      _revision = rev;
      _revision?.addListener(_onRemoteSync);
    }
  }

  void _onRemoteSync() {
    if (mounted) _loadDueQueue();
  }

  @override
  void dispose() {
    _revision?.removeListener(_onRemoteSync);
    super.dispose();
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
    _scope.requestSync?.call(); // push this review to the cloud promptly

    setState(() {
      _reviewsCompletedThisSession += 1;
    });

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

    if (!_scope.isPremium && _reviewsCompletedThisSession >= 10) {
      return Scaffold(
        backgroundColor: t.bgBase,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Daily Review Limit Reached',
                    style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Free tier is limited to 10 card reviews per day. Upgrade to Premium to study all remaining due cards.',
                    style: AppTypography.body(t).copyWith(color: t.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CalmButton.primary(
                    text: 'Unlock Premium',
                    onPressed: () => PaywallScreen.show(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                    'No cards are due right now. Finish a lesson to add new cards — they return here for spaced recall as they fall due.',
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
                      firstChild: _buildFrontCard(t, card),
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

  /// A short recall cue — the concept card's bold title (or its first line).
  String _cardCue(Card? card) {
    if (card == null) return '';
    for (final b in card.blocks) {
      if (b is TextBlock) {
        final md = b.md.resolve('en').trim();
        final bold = RegExp(r'^\s*\*\*(.+?)\*\*').firstMatch(md);
        if (bold != null) return bold.group(1)!.trim();
        final firstLine = md.split('\n').first.trim();
        return firstLine.length > 70
            ? '${firstLine.substring(0, 70)}…'
            : firstLine;
      }
    }
    return '';
  }

  Widget _buildFrontCard(AppTokens t, Card? card) {
    final cue = _cardCue(card);
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
          'Recall everything you can about:',
          style: AppTypography.body(t).copyWith(height: 1.6, color: t.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          cue.isEmpty ? 'this concept' : cue,
          style: AppTypography.title(t).copyWith(color: t.textPrimary),
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
