import 'package:flutter/material.dart';
import 'package:store/store.dart';
import '../components/card.dart';
import '../components/progress_ring.dart';
import '../components/button.dart';
import '../theme/tokens.dart';
import '../data/learning_repository.dart';
import '../app_scope.dart';
import 'lesson_player_screen.dart';

/// The calm home: one clear action ("Today's 5 minutes"), a gentle progress
/// ring, and a non-stressful weekly streak. Mocks live on their own tab;
/// developer/diagnostics tooling is not part of the shipping UI.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  int _completedCount = 0;
  bool _studiedToday = false;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadStats();
    });
  }

  Future<void> _loadStats() async {
    final stats =
        await _repo.homeStats(_scope.userId, trackLessonId: 'les_ppb_crr');
    if (mounted) {
      setState(() {
        _completedCount = stats.completedCount;
        _studiedToday = stats.studiedToday;
      });
    }
  }

  Future<void> _startDailyLesson() async {
    setState(() => _isLoading = true);
    try {
      final lesson = await _repo.getLesson('les_ppb_crr');
      if (lesson == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson not ready yet. Please try again.')),
          );
        }
        return;
      }
      final questions = await _repo.getLessonQuestions('les_ppb_crr');

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LessonPlayerScreen(
            lesson: lesson,
            questions: questions,
            stimuli: const [],
            userId: _scope.userId,
            onComplete: (events) async {
              Navigator.of(context).pop();
              await _handleLessonComplete(events);
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLessonComplete(List<SrsEvent> events) async {
    await _repo.applyLessonCompletion(_scope.userId, _scope.examName, events);
    await _loadStats();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final t = context.tokens;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final settings = _scope.notificationService.settings;
            return Container(
              decoration: BoxDecoration(
                color: t.bgSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: AppTypography.title(t)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Daily reminder', style: AppTypography.body(t)),
                    subtitle: Text('A gentle nudge when reviews are due',
                        style: AppTypography.caption(t)),
                    value: settings.enabled,
                    activeColor: t.accent,
                    onChanged: (val) {
                      _scope.notificationService.updateSettings(
                        enabled: val,
                        hour: settings.hour,
                        minute: settings.minute,
                      );
                      setSheetState(() {});
                    },
                  ),
                  if (settings.enabled)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Reminder time', style: AppTypography.body(t)),
                      trailing: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.body(t).copyWith(color: t.accent),
                        ),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: settings.hour, minute: settings.minute),
                        );
                        if (picked != null) {
                          _scope.notificationService.updateSettings(
                            enabled: settings.enabled,
                            hour: picked.hour,
                            minute: picked.minute,
                          );
                          setSheetState(() {});
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final remainingDays = _scope.examDate.difference(DateTime.now()).inDays;
    final progress = _completedCount / 20.0;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_scope.examName, style: AppTypography.heading(t)),
                      const SizedBox(height: 4),
                      Text(
                        remainingDays > 0
                            ? '$remainingDays days until exam'
                            : 'Exam day',
                        style: AppTypography.caption(t),
                      ),
                    ],
                  ),
                  Semantics(
                    button: true,
                    label: 'Settings',
                    child: IconButton(
                      icon: Icon(Icons.settings_outlined, color: t.textSecondary),
                      onPressed: _showSettingsSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // The one clear action.
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's 5 minutes", style: AppTypography.title(t)),
                        Icon(Icons.timer_outlined, size: 20, color: t.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A short, calm session: a couple of micro-cards and a quick recall check.',
                      style: AppTypography.body(t).copyWith(color: t.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: t.accent))
                    else
                      CalmButton.primary(
                        text: 'Begin',
                        onPressed: _startDailyLesson,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gentle progress.
              CalmCard(
                child: Row(
                  children: [
                    CalmProgressRing(progress: progress, size: 60),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Principles & practices of banking',
                              style: AppTypography.heading(t)),
                          const SizedBox(height: 4),
                          Text('Module A · Indian financial system',
                              style: AppTypography.bodySm(t)),
                          const SizedBox(height: 6),
                          Text('$_completedCount of 20 lessons',
                              style: AppTypography.caption(t)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Calm, non-stressful weekly habit.
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This week', style: AppTypography.heading(t)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _streakDay(t, 'M', true),
                        _streakDay(t, 'T', true),
                        _streakDay(t, 'W', _studiedToday),
                        _streakDay(t, 'T', false),
                        _streakDay(t, 'F', false),
                        _streakDay(t, 'S', false),
                        _streakDay(t, 'S', false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _studiedToday
                          ? 'You studied today. Nicely done.'
                          : 'Learn when you are ready — no pressure.',
                      style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
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

  Widget _streakDay(AppTokens t, String dayLetter, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? t.accentSoft : Colors.transparent,
        border: Border.all(color: active ? t.accent : t.border, width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        dayLetter,
        style: AppTypography.micro(t).copyWith(
          color: active ? t.accent : t.textSecondary,
          fontWeight: active ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
