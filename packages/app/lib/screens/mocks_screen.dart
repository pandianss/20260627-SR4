import 'package:flutter/material.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../theme/tokens.dart';
import '../data/learning_repository.dart';
import 'mock_player_screen.dart';

/// The Mocks tab: a single calm action to start a practice mock assembled from
/// the question bank. Assembly logic is intentionally thin here — it will move
/// behind a controller in a later cleanup.
class MocksScreen extends StatefulWidget {
  final ContentStore contentStore;
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final Scheduler scheduler;
  final String userId;
  final String examName;
  final ExamConfig examConfig;

  const MocksScreen({
    super.key,
    required this.contentStore,
    required this.eventStore,
    required this.stateStore,
    required this.scheduler,
    required this.userId,
    required this.examName,
    required this.examConfig,
  });

  @override
  State<MocksScreen> createState() => _MocksScreenState();
}

class _MocksScreenState extends State<MocksScreen> {
  bool _isLoading = false;

  late final LearningRepository _repo = LearningRepository(
    content: widget.contentStore,
    events: widget.eventStore,
    states: widget.stateStore,
    scheduler: widget.scheduler,
  );

  Future<void> _startMock() async {
    setState(() => _isLoading = true);
    try {
      final mock = await _repo.assembleMockForPaper(widget.examConfig,
          paperContentId: 'p_ppb');

      if (mock.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available yet.')),
          );
        }
        return;
      }

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MockPlayerScreen(
            blueprint: mock.blueprint,
            questions: mock.questions,
            stimuli: const [],
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Practice mocks', style: AppTypography.title(t)),
              const SizedBox(height: 24),
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full mock', style: AppTypography.heading(t)),
                    const SizedBox(height: 12),
                    Text(
                      'A timed mock assembled from the question bank. Your weak answers come back as spaced reviews.',
                      style: AppTypography.body(t).copyWith(color: t.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: t.accent))
                    else
                      CalmButton.primary(
                        text: 'Start mock',
                        onPressed: _startMock,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
