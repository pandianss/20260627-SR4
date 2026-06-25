import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import '../components/card.dart';
import '../data/learning_repository.dart';
import '../app_scope.dart';
import '../theme/tokens.dart';
import 'lesson_player_screen.dart';
import 'paywall_screen.dart';

// ─── Local tree nodes (UI state only) ────────────────────────────────────────

class _ModuleNode {
  final Module module;
  final List<Lesson> lessons;
  bool expanded;
  _ModuleNode({required this.module, required this.lessons, this.expanded = false});
}

class _PaperNode {
  final Paper paper;
  final List<_ModuleNode> modules;
  final Color color;
  bool expanded;
  _PaperNode({
    required this.paper,
    required this.modules,
    required this.color,
    this.expanded = false,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ContentBrowserScreen extends StatefulWidget {
  const ContentBrowserScreen({super.key});

  @override
  State<ContentBrowserScreen> createState() => _ContentBrowserScreenState();
}

class _ContentBrowserScreenState extends State<ContentBrowserScreen> {
  List<_PaperNode> _tree = [];
  Set<String> _completed = {};
  Set<String> _unlockedLessonIds = {};
  bool _loading = true;

  AppScope get _scope => AppScope.of(context);
  LearningRepository get _repo => _scope.repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final catalog = await _repo.browseCatalog(_scope.examName, _scope.userId);
      final tree = <_PaperNode>[];
      for (var i = 0; i < catalog.papers.length; i++) {
        final paper = catalog.papers[i];
        final mods = catalog.modulesByPaper[paper.id] ?? [];
        final modNodes = mods.map((mod) {
          final lessons = catalog.lessonsByModule[mod.id] ?? [];
          return _ModuleNode(module: mod, lessons: lessons);
        }).toList();
        tree.add(_PaperNode(
          paper: paper,
          modules: modNodes,
          color: paperPalette[i % paperPalette.length],
        ));
      }
      if (tree.isNotEmpty) tree[0].expanded = true;

      final allLessonIds = <String>[];
      for (final p in tree) {
        for (final m in p.modules) {
          for (final l in m.lessons) {
            allLessonIds.add(l.id);
          }
        }
      }
      final totalLessonsCount = allLessonIds.length;
      final unlockedCount = (totalLessonsCount * 0.05).ceil().clamp(3, totalLessonsCount);
      final unlockedLessonIds = allLessonIds.take(unlockedCount).toSet();

      if (mounted) {
        setState(() {
          _tree = tree;
          _completed = catalog.completed;
          _unlockedLessonIds = unlockedLessonIds;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLesson(Lesson lesson) async {
    final questions = await _repo.getLessonQuestions(lesson.id);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPlayerScreen(
          lesson: lesson,
          questions: questions,
          stimuli: const [],
          userId: _scope.userId,
          onComplete: (events) async {
            Navigator.of(context).pop();
            await _repo.applyLessonCompletion(_scope.userId, _scope.examName, events);
            _load();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    int total = 0;
    for (final p in _tree) {
      for (final m in p.modules) { total += m.lessons.length; }
    }

    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Topics', style: AppTypography.display(t)),
                  const SizedBox(height: 4),
                  Text(
                    _loading ? 'Loading…' : '$total lessons · ${_completed.length} completed',
                    style: AppTypography.bodySm(t),
                  ),
                ],
              ),
            ),

            if (_loading)
              Expanded(child: Center(child: CircularProgressIndicator(color: t.accent)))
            else
              Expanded(
                child: RefreshIndicator(
                  color: t.accent,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: _tree.length,
                    itemBuilder: (ctx, pi) => _buildPaperCard(pi, t),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Coloured paper bento card ─────────────────────────────────────────────

  Widget _buildPaperCard(int pi, AppTokens t) {
    final node = _tree[pi];
    int total = 0, done = 0;
    for (final m in node.modules) {
      total += m.lessons.length;
      done += m.lessons.where((l) => _completed.contains(l.id)).length;
    }
    final progress = total > 0 ? done / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coloured paper card
          GestureDetector(
            onTap: () => setState(() => node.expanded = !node.expanded),
            child: BentoTile(
              fillColor: node.color,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Paper index pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'PAPER ${pi + 1}',
                          style: AppTypography.pill(t).copyWith(color: t.ink),
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: node.expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more, color: t.ink.withOpacity(0.7), size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    node.paper.name.resolve('en'),
                    style: AppTypography.title(t).copyWith(color: t.ink),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: progress),
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.black.withOpacity(0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.lerp(t.ink.withOpacity(0.4), t.ink, value)!,
                                ),
                                minHeight: 4,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$done / $total',
                        style: AppTypography.caption(t).copyWith(color: t.ink.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Module accordion (white bg, below card)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: node.expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(
              decoration: BoxDecoration(
                color: t.bgSurface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: List.generate(node.modules.length, (mi) => _buildModule(pi, mi, t)),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ─── Module row ────────────────────────────────────────────────────────────

  Widget _buildModule(int pi, int mi, AppTokens t) {
    final paperNode = _tree[pi];
    final node = paperNode.modules[mi];
    final done = node.lessons.where((l) => _completed.contains(l.id)).length;
    final total = node.lessons.length;
    final isLast = mi == paperNode.modules.length - 1;
    final progress = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => node.expanded = !node.expanded),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              border: !isLast || node.expanded
                  ? Border(bottom: BorderSide(color: t.border))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Module tag pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.bgBase,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'M${mi + 1}',
                        style: AppTypography.pill(t).copyWith(color: t.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        node.module.name.resolve('en'),
                        style: AppTypography.heading(t).copyWith(
                          color: t.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text('$done/$total', style: AppTypography.caption(t)),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: node.expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more, color: t.textTertiary, size: 18),
                    ),
                  ],
                ),
                // ── Lesson-dot progress strip ──────────────────────────
                if (total > 0) ...[
                  const SizedBox(height: 8),
                  _LessonDotStrip(
                    lessons: node.lessons,
                    completed: _completed,
                    color: paperNode.color,
                    t: t,
                  ),
                ],
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: node.expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            children: node.lessons.map((l) => _buildLessonRow(l, isLast: node.lessons.last == l && isLast, t: t)).toList(),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }


  // ─── Lesson row ────────────────────────────────────────────────────────────

  Widget _buildLessonRow(Lesson lesson, {required bool isLast, required AppTokens t}) {
    final isDone = _completed.contains(lesson.id);
    final isUnlocked = _scope.isPremium || _unlockedLessonIds.contains(lesson.id);
    
    return InkWell(
      onTap: isUnlocked ? () => _openLesson(lesson) : () => PaywallScreen.show(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        decoration: BoxDecoration(
          border: !isLast ? Border(bottom: BorderSide(color: t.border.withOpacity(0.6))) : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 36),
            Container(
              width: 20, height: 20,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone 
                    ? t.sage 
                    : (!isUnlocked ? t.border.withOpacity(0.4) : Colors.transparent),
                border: Border.all(
                  color: isDone 
                      ? t.accent 
                      : (!isUnlocked ? t.borderStrong : t.border),
                  width: 1.5,
                ),
              ),
              child: isDone 
                  ? Icon(Icons.check, size: 11, color: t.ink) 
                  : (!isUnlocked ? Icon(Icons.lock, size: 10, color: t.textTertiary) : null),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title.resolve('en'),
                    style: AppTypography.body(t).copyWith(
                      color: !isUnlocked 
                          ? t.textTertiary 
                          : (isDone ? t.textSecondary : t.textPrimary),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lesson.estMinutes} min · ${lesson.cards.length} cards',
                    style: AppTypography.caption(t),
                  ),
                ],
              ),
            ),
            Icon(
              isUnlocked ? Icons.chevron_right : Icons.lock_outline, 
              size: 18, 
              color: isUnlocked ? t.textTertiary : Colors.amber[800],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lesson dot strip ─────────────────────────────────────────────────────────

/// A horizontal row of small dots — one per lesson in the module.
/// Completed dots fill with the paper's colour; pending dots are empty.
/// Animates on state change using AnimatedContainer.
class _LessonDotStrip extends StatelessWidget {
  final List<dynamic> lessons; // List<Lesson>
  final Set<String> completed;
  final Color color;
  final AppTokens t;

  const _LessonDotStrip({
    required this.lessons,
    required this.completed,
    required this.color,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: lessons.map((l) {
        final isDone = completed.contains(l.id as String);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? color : Colors.transparent,
            border: Border.all(
              color: isDone
                  ? color.withOpacity(0.8)
                  : t.border,
              width: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}
