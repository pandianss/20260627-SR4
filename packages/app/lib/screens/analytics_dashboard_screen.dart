import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../components/card.dart';
import '../components/progress_ring.dart';
import '../components/pill.dart';
import '../services/analytics_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  final String userId;
  final AnalyticsService analyticsService;

  const AnalyticsDashboardScreen({
    super.key,
    required this.userId,
    required this.analyticsService,
  });

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _loading = true;
  UserAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final analytics = await widget.analyticsService.calculateAnalytics(widget.userId);
    if (mounted) {
      setState(() {
        _analytics = analytics;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Developer Analytics',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: t.accent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome & DAU/MAU
                    Text(
                      'Pilot Progress Overview',
                      style: AppTypography.caption(t).copyWith(color: t.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User ID: ${widget.userId}',
                      style: AppTypography.heading(t).copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),

                    // Grid of DAU & MAU
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            t,
                            title: 'Active Days (DAU)',
                            value: '${_analytics!.dau}',
                            icon: Icons.calendar_month_outlined,
                            iconColor: t.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            t,
                            title: 'Active Months (MAU)',
                            value: '${_analytics!.mau}',
                            icon: Icons.date_range_outlined,
                            iconColor: t.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Streak Card
                    CalmCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_fire_department, color: Color(0xFFF57C00), size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Current Streak', style: AppTypography.caption(t)),
                                Text(
                                  '${_analytics!.currentStreak} Days',
                                  style: AppTypography.title(t).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Longest Streak', style: AppTypography.caption(t)),
                              Text(
                                '${_analytics!.longestStreak} Days',
                                style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cohort Retention
                    Text(
                      'Pilot Cohort Retention',
                      style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    CalmCard(
                      child: Column(
                        children: [
                          _buildRetentionRow(
                            t,
                            dayLabel: 'Day 1 (D1) Retention',
                            description: 'User studied on Day 1 relative to first session',
                            isRetained: _analytics!.d1Retention > 0,
                          ),
                          const Divider(height: 24),
                          _buildRetentionRow(
                            t,
                            dayLabel: 'Day 7 (D7) Retention',
                            description: 'User studied on Day 7 relative to first session',
                            isRetained: _analytics!.d7Retention > 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lesson Progress
                    Text(
                      'Lesson Completion Analysis',
                      style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    CalmCard(
                      child: Row(
                        children: [
                          CalmProgressRing(
                            progress: _analytics!.completionRate,
                            size: 70,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Finished Lessons',
                                  style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_analytics!.completedLessonsCount} lessons completed',
                                  style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(_analytics!.completionRate * 100).toStringAsFixed(0)}%',
                            style: AppTypography.title(t).copyWith(fontWeight: FontWeight.w600, color: t.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mock Exams Performance
                    Text(
                      'Mock Exams Summary',
                      style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    CalmCard(
                      child: Column(
                        children: [
                          _buildPerformanceRow(
                            t,
                            label: 'Total Mock Attempts',
                            value: '${_analytics!.mockAttemptsCount}',
                            icon: Icons.edit_note,
                          ),
                          const Divider(height: 16),
                          _buildPerformanceRow(
                            t,
                            label: 'Average Mock Score',
                            value: '${(_analytics!.averageMockScore * 100).toStringAsFixed(1)}%',
                            icon: Icons.score_outlined,
                          ),
                          const Divider(height: 16),
                          _buildPerformanceRow(
                            t,
                            label: 'Mock Pass Rate',
                            value: '${(_analytics!.mockPassRate * 100).toStringAsFixed(0)}%',
                            icon: Icons.verified_user_outlined,
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

  Widget _buildMetricCard(
    AppTokens t, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.caption(t)),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.title(t).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionRow(
    AppTokens t, {
    required String dayLabel,
    required String description,
    required bool isRetained,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dayLabel, style: AppTypography.heading(t).copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(description, style: AppTypography.caption(t)),
            ],
          ),
        ),
        CalmPill(
          label: isRetained ? 'Retained' : 'No Record',
          color: isRetained ? t.accent : t.border,
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(
    AppTokens t, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.body(t)),
          ],
        ),
        Text(
          value,
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w600, color: t.textPrimary),
        ),
      ],
    );
  }
}
