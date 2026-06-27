import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/store.dart';
import '../components/card.dart';
import '../components/progress_ring.dart';
import '../theme/tokens.dart';
import '../data/learning_repository.dart';
import '../app_scope.dart';
import 'lesson_player_screen.dart';
import 'paywall_screen.dart';
import 'sign_in_screen.dart';

/// Editorial home screen — dark hero header, bento stat tiles, calm weekly habit strip.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  HomeData? _data;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;
  Listenable? _revision;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh progress live when another device's activity merges in.
    final rev = AppScope.of(context).syncRevision;
    if (!identical(rev, _revision)) {
      _revision?.removeListener(_onRemoteSync);
      _revision = rev;
      _revision?.addListener(_onRemoteSync);
    }
  }

  void _onRemoteSync() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    _revision?.removeListener(_onRemoteSync);
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _repo.homeData(_scope.examName, _scope.userId);
    if (mounted) setState(() => _data = data);
  }

  Future<void> _startDailyLesson() async {
    final lesson = _data?.nextLesson;
    if (lesson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lessons are still loading. Please try again.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final questions = await _repo.getLessonQuestions(lesson.id);
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
    _scope.requestSync?.call();
    await _load();
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
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: t.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: AppTypography.title(t)),
                      IconButton(
                        icon: Icon(Icons.close, color: t.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Daily reminder', style: AppTypography.body(t)),
                    subtitle: Text('A gentle nudge when reviews are due',
                        style: AppTypography.caption(t)),
                    value: settings.enabled,
                    activeColor: t.accent,
                    onChanged: (val) {
                      _scope.notificationService.updateSettings(
                        enabled: val, hour: settings.hour, minute: settings.minute,
                      );
                      setSheetState(() {});
                    },
                  ),
                  if (settings.enabled)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Reminder time', style: AppTypography.body(t)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.sage,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.heading(t).copyWith(color: t.ink),
                        ),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
                        );
                        if (picked != null) {
                          _scope.notificationService.updateSettings(
                            enabled: settings.enabled, hour: picked.hour, minute: picked.minute,
                          );
                          setSheetState(() {});
                        }
                      },
                    ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.brightness_6_outlined,
                          color: t.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text('Appearance', style: AppTypography.body(t)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(
                          value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {_scope.themeMode},
                    onSelectionChanged: (sel) {
                      _scope.onSetThemeMode?.call(sel.first);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _scope.isPremium ? Icons.verified_user : Icons.stars,
                      color: _scope.isPremium ? t.accent : Colors.amber,
                    ),
                    title: Text(
                      _scope.isPremium ? 'Premium Plan Active' : 'Upgrade to Premium',
                      style: AppTypography.body(t).copyWith(
                        fontWeight: FontWeight.bold,
                        color: _scope.isPremium ? t.accent : Colors.amber[800],
                      ),
                    ),
                    subtitle: Text(
                      _scope.isPremium ? 'Thank you for supporting SuperRecall Banker!' : 'Unlock unlimited card reviews and all mock exams',
                      style: AppTypography.caption(t),
                    ),
                    trailing: _scope.isPremium
                        ? null
                        : Icon(Icons.chevron_right, color: Colors.amber[800]),
                    onTap: _scope.isPremium
                        ? null
                        : () {
                            Navigator.pop(context);
                            PaywallScreen.show(context);
                          },
                  ),
                  const SizedBox(height: 8),
                  if (_scope.authService != null &&
                      !_scope.authService!.isSignedInWithAccount) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cloud_sync_outlined, color: t.accent),
                      title:
                          Text('Sign in to sync', style: AppTypography.body(t)),
                      subtitle: Text('Back up & sync across your devices',
                          style: AppTypography.caption(t)),
                      trailing: Icon(Icons.chevron_right, color: t.textTertiary),
                      onTap: () async {
                        Navigator.pop(context);
                        final ok = await SignInScreen.show(
                            this.context, _scope.authService!);
                        if (!mounted) return;
                        if (ok == true) {
                          setState(() {});
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Signed in — your progress will sync.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('Sign Out', style: AppTypography.body(t).copyWith(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      if (_scope.onLogout != null) {
                        _scope.onLogout!();
                      }
                    },
                  ),
                  if (_scope.onDeleteAccount != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_forever_outlined,
                          color: t.textTertiary),
                      title: Text('Delete account',
                          style: AppTypography.body(t)
                              .copyWith(color: t.textSecondary)),
                      subtitle: Text(
                          'Permanently remove your account and all progress',
                          style: AppTypography.caption(t)),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete account?'),
                            content: const Text(
                                'This permanently deletes your account and all your progress. This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete',
                                      style:
                                          TextStyle(color: Colors.redAccent))),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        if (context.mounted) Navigator.pop(context);
                        try {
                          await _scope.onDeleteAccount!.call();
                        } catch (_) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text(
                                  'Couldn\'t delete the account. Please sign in again and retry.')));
                        }
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final data = _data;
    final remainingDays = _scope.examDate.difference(DateTime.now()).inDays;
    final total = data?.totalLessons ?? 0;
    final completed = data?.completedCount ?? 0;
    final studiedToday = data?.studiedToday ?? false;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Dark hero header ────────────────────────────────────────
              _HeroHeader(
                examName: _scope.examName,
                remainingDays: remainingDays,
                lessonTitle: data?.nextLesson?.title.resolve('en') ?? 'Loading…',
                moduleName: data?.moduleName ?? '',
                isLoading: _isLoading,
                onBegin: _startDailyLesson,
                onSettings: _showSettingsSheet,
                t: t,
              ),

              if (!_scope.isPremium)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Free Tier Active',
                                style: AppTypography.body(t).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Upgrade to unlock all mock tests and unlimited reviews.',
                                style: AppTypography.caption(t),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => PaywallScreen.show(context),
                          child: Text(
                            'UPGRADE',
                            style: AppTypography.caption(t).copyWith(color: Colors.amber[800], fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Bento stat tiles ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: BentoTile(
                        fillColor: t.sage,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completed',
                              style: AppTypography.hero(t).copyWith(fontSize: 36),
                            ),
                            const SizedBox(height: 4),
                            Text('lessons done', style: AppTypography.bodySm(t).copyWith(
                              color: t.ink.withOpacity(0.65),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoTile(
                        fillColor: t.amber,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              total > 0
                                  ? '${(progress * 100).round()}%'
                                  : '—',
                              style: AppTypography.hero(t).copyWith(fontSize: 36),
                            ),
                            const SizedBox(height: 4),
                            Text('overall progress', style: AppTypography.bodySm(t).copyWith(
                              color: t.ink.withOpacity(0.65),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress context ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CalmCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CalmProgressRing(progress: progress, size: 52),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (data?.paperName.isNotEmpty ?? false)
                                  ? data!.paperName
                                  : _scope.examName,
                              style: AppTypography.heading(t),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              (data?.moduleName.isNotEmpty ?? false)
                                  ? data!.moduleName
                                  : 'Loading…',
                              style: AppTypography.bodySm(t),
                            ),
                            const SizedBox(height: 3),
                            Text('$completed of $total lessons',
                                style: AppTypography.caption(t)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Weekly habit ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: CalmCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This week', style: AppTypography.heading(t)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _streakDay(t, 'M', true),
                          _streakDay(t, 'T', true),
                          _streakDay(t, 'W', studiedToday),
                          _streakDay(t, 'T', false),
                          _streakDay(t, 'F', false),
                          _streakDay(t, 'S', false),
                          _streakDay(t, 'S', false),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        studiedToday
                            ? 'You studied today. Nicely done.'
                            : 'Learn when you are ready — no pressure.',
                        style: AppTypography.bodySm(t),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streakDay(AppTokens t, String d, bool active) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? t.sage : Colors.transparent,
        border: Border.all(
          color: active ? t.ink.withOpacity(0.25) : t.border,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        d,
        style: AppTypography.micro(t).copyWith(
          color: active ? t.ink : t.textTertiary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Dark hero header ─────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String examName;
  final int remainingDays;
  final String lessonTitle;
  final String moduleName;
  final bool isLoading;
  final VoidCallback onBegin;
  final VoidCallback onSettings;
  final AppTokens t;

  const _HeroHeader({
    required this.examName,
    required this.remainingDays,
    required this.lessonTitle,
    required this.moduleName,
    required this.isLoading,
    required this.onBegin,
    required this.onSettings,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '$examName · $remainingDays days left',
                      style: AppTypography.micro(t).copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: 'Settings',
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                  onPressed: onSettings,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Greeting
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.5,
              ),
              children: const [
                TextSpan(text: 'Hi 👋\n'),
                TextSpan(
                  text: 'Ready to study?',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Today's lesson pill card
          GestureDetector(
            onTap: isLoading ? null : onBegin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFC5E1C8), // sage
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Lesson",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lessonTitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1A1A1A), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
