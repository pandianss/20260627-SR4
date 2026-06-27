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
  String? _regulator; // issuing body filter; null = all
  String? _month; // "yyyy-MM" filter; null = all

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

  static String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  Widget _list(AppTokens t, UpdatesResult r) {
    final all = r.feed.updates;

    // Issuing bodies present, in a sensible order.
    const order = ['RBI', 'SEBI', 'IRDAI', 'IIBF'];
    final regulators = all.map((u) => u.regulator).toSet().toList()
      ..sort((a, b) {
        final ia = order.indexOf(a), ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    // Months present, newest first.
    final months = all.map((u) => _monthKey(u.publishedAt)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    String monthLabel(String key) {
      final p = key.split('-');
      return '${_months[int.parse(p[1]) - 1]} ${p[0]}';
    }

    final filtered = all.where((u) {
      if (_regulator != null && u.regulator != _regulator) return false;
      if (_month != null && _monthKey(u.publishedAt) != _month) return false;
      return true;
    }).toList();

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
        const SizedBox(height: 12),
        _filterRow(
          t,
          icon: Icons.account_balance_outlined,
          options: [for (final reg in regulators) (reg, reg)],
          selected: _regulator,
          onSelected: (v) => setState(() => _regulator = v),
        ),
        const SizedBox(height: 8),
        _filterRow(
          t,
          icon: Icons.calendar_today_outlined,
          options: [for (final m in months) (m, monthLabel(m))],
          selected: _month,
          onSelected: (v) => setState(() => _month = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${filtered.length} update${filtered.length == 1 ? '' : 's'}'
              '${(_regulator != null || _month != null) ? ' · filtered' : ''}',
              style: AppTypography.micro(t).copyWith(color: t.textTertiary),
            ),
            const Spacer(),
            _sourceLine(t, r),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              all.isEmpty
                  ? 'No updates yet. Pull to refresh.'
                  : 'No updates match these filters.',
              style: AppTypography.body(t).copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final u in filtered) ...[
            _UpdateCard(
                update: u, isNew: _isNew(u), onOpen: () => _open(u.sourceUrl)),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  /// A horizontally-scrolling row of filter chips with a leading icon and an
  /// "All" reset chip.
  Widget _filterRow(
    AppTokens t, {
    required IconData icon,
    required List<(String, String)> options,
    required String? selected,
    required void Function(String?) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Icon(icon, size: 16, color: t.textTertiary),
          const SizedBox(width: 8),
          _chip(t, 'All', selected == null, () => onSelected(null)),
          for (final (value, label) in options) ...[
            const SizedBox(width: 6),
            _chip(t, label, selected == value, () => onSelected(value)),
          ],
        ],
      ),
    );
  }

  Widget _chip(AppTokens t, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? t.accent : t.bgSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? t.accent : t.border),
        ),
        child: Text(
          label,
          style: AppTypography.caption(t).copyWith(
            color: active ? t.onAccent : t.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
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
