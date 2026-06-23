import 'package:flutter/material.dart';
import '../components/card.dart';
import '../components/button.dart';
import '../theme/tokens.dart';
import '../data/learning_repository.dart';
import '../app_scope.dart';
import 'mock_player_screen.dart';

/// The Mocks tab: a single calm action to start a practice mock assembled from
/// the question bank. Assembly logic is intentionally thin here — it will move
/// behind a controller in a later cleanup.
class MocksScreen extends StatefulWidget {
  const MocksScreen({super.key});

  @override
  State<MocksScreen> createState() => _MocksScreenState();
}

class _MocksScreenState extends State<MocksScreen> {
  bool _isLoading = false;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;

  Future<void> _startMock() async {
    setState(() => _isLoading = true);
    try {
      final mock = await _repo.assembleMockForExam(_scope.examConfig);

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
            userId: _scope.userId,
            contentStore: _repo.content,
            eventStore: _repo.events,
            stateStore: _repo.states,
            scheduler: _repo.scheduler,
            examName: _scope.examName,
            examConfig: _scope.examConfig,
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
