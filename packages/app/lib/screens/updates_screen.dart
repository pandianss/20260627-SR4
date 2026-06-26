import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../components/card.dart';
import '../components/pill.dart';
import '../models/regulatory_update.dart';
import '../services/updates_service.dart';
import '../theme/tokens.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String _ago(DateTime? d) {
  if (d == null) return 'just now';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// The Updates tab: curated, plain-language summaries of recent updates from
/// financial regulators (RBI, SEBI, IRDAI, IIBF). Educational only — each item
/// links out to the official notification.
class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  late Future<UpdatesResult> _future;
  DateTime? _seenBefore;
  bool _started = false;

  UpdatesService get _service => AppScope.of(context).updatesService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = _load();
  }

  Future<UpdatesResult> _load({bool force = false}) async {
    // Capture the previous "seen" watermark before marking, so freshly arrived
    // items can be flagged NEW in this session.
    _seenBefore = await _service.lastSeen();
    final result = await _service.load(forceRefresh: force);
    await _service.markSeen();
    return result;
  }

  Future<void> _refresh() async {
    final result = await _load(force: true);
    if (mounted) setState(() => _future = Future.value(result));
  }

  bool _isNew(RegulatoryUpdate u) =>
      _seenBefore == null || u.publishedAt.isAfter(_seenBefore!);

  Future<void> _open(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: RefreshIndicator(
          color: t.accent,
          onRefresh: _refresh,
          child: FutureBuilder<UpdatesResult>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return _scrollable(
                  Center(child: CircularProgressIndicator(color: t.accent)),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return _scrollable(
                  Text(
                    'Updates are unavailable right now. Pull to retry.',
                    style: AppTypography.body(t).copyWith(color: t.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return _list(t, snap.data!);
            },
          ),
        ),
      ),
    );
  }

  /// Wrap a single child so the pull-to-refresh gesture still works while
  /// loading / empty.
  Widget _scrollable(Widget child) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        children: [child],
      );

  Widget _list(AppTokens t, UpdatesResult r) {
    final updates = r.feed.updates;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        const SizedBox(height: 8),
        Text('Regulatory updates', style: AppTypography.title(t)),
        const SizedBox(height: 4),
        Text(
          'RBI · SEBI · IRDAI · IIBF',
          style: AppTypography.caption(t).copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: 16),
        _disclaimer(t),
        const SizedBox(height: 10),
        _sourceLine(t, r),
        const SizedBox(height: 16),
        if (updates.isEmpty)
          Text(
            'No updates yet. Pull to refresh.',
            style: AppTypography.body(t).copyWith(color: t.textSecondary),
          )
        else
          for (final u in updates) ...[
            _UpdateCard(update: u, isNew: _isNew(u), onOpen: () => _open(u.sourceUrl)),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _disclaimer(AppTokens t) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: t.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Educational summaries — always refer to the official notification. '
                'Not affiliated with or endorsed by any regulator.',
                style: AppTypography.caption(t).copyWith(color: t.textSecondary),
              ),
            ),
          ],
        ),
      );

  Widget _sourceLine(AppTokens t, UpdatesResult r) {
    final label = switch (r.source) {
      UpdatesSource.network => 'Updated ${_ago(r.fetchedAt)}',
      UpdatesSource.cache => 'Showing saved updates · ${_ago(r.fetchedAt)}',
      UpdatesSource.bundled => 'Showing bundled samples · pull to refresh',
    };
    return Row(
      children: [
        Icon(Icons.sync, size: 14, color: t.textTertiary),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.micro(t).copyWith(color: t.textTertiary)),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final RegulatoryUpdate update;
  final bool isNew;
  final VoidCallback onOpen;

  const _UpdateCard({
    required this.update,
    required this.isNew,
    required this.onOpen,
  });

  (String, Color) _priorityChip(AppTokens t) => switch (update.priority) {
        UpdatePriority.critical => ('Critical', t.danger),
        UpdatePriority.important => ('Important', t.warning),
        UpdatePriority.normal => ('Update', t.accent),
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (priorityLabel, priorityColor) = _priorityChip(t);
    final hasLink = update.sourceUrl != null;

    return GestureDetector(
      onTap: hasLink ? onOpen : null,
      behavior: HitTestBehavior.opaque,
      child: CalmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CalmPill(label: update.regulator, color: t.ink, textColor: Colors.white),
                const SizedBox(width: 6),
                CalmPill(label: priorityLabel, color: priorityColor, textColor: Colors.white),
                const Spacer(),
                if (isNew)
                  CalmPill(label: 'NEW', color: t.sage, textColor: t.ink),
              ],
            ),
            const SizedBox(height: 12),
            Text(update.title, style: AppTypography.heading(t)),
            const SizedBox(height: 6),
            Text(
              update.summary,
              style: AppTypography.body(t).copyWith(color: t.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _fmtDate(update.publishedAt),
                  style: AppTypography.micro(t).copyWith(color: t.textTertiary),
                ),
                if (update.category.isNotEmpty) ...[
                  Text('  ·  ',
                      style: AppTypography.micro(t).copyWith(color: t.textTertiary)),
                  Flexible(
                    child: Text(
                      update.category,
                      style: AppTypography.micro(t).copyWith(color: t.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                if (hasLink) ...[
                  Text('Read source',
                      style: AppTypography.micro(t).copyWith(
                        color: t.accentText,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(width: 2),
                  Icon(Icons.north_east, size: 12, color: t.accentText),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
