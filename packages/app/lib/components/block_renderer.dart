import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import '../theme/tokens.dart';

class ContentBlockRenderer extends StatelessWidget {
  final ContentBlock block;

  const ContentBlockRenderer({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return switch (block) {
      TextBlock() => _buildTextBlock(context, block as TextBlock, t),
      MediaBlock() => _buildMediaBlock(context, block as MediaBlock, t),
      FormulaBlock() => _buildFormulaBlock(context, block as FormulaBlock, t),
      ChartBlock() => _buildChartBlock(context, block as ChartBlock, t),
    };
  }

  Widget _buildTextBlock(BuildContext context, TextBlock b, AppTokens t) {
    final mdString = b.md.resolve('en'); // fallback to English for now

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        mdString,
        style: AppTypography.body(t).copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildMediaBlock(BuildContext context, MediaBlock b, AppTokens t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: t.bgBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              b.mediaKind == 'audio'
                  ? Icons.audiotrack_outlined
                  : Icons.image_outlined,
              color: t.accent,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              b.alt.resolve('en'),
              style: AppTypography.caption(t),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaBlock(BuildContext context, FormulaBlock b, AppTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: t.bgBase,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          b.latex,
          style: AppTypography.heading(t).copyWith(
            fontStyle: FontStyle.italic,
            fontFamily: 'monospace',
            color: t.accent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChartBlock(BuildContext context, ChartBlock b, AppTokens t) {
    // Simple custom painted chart based on spec specifications
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: t.bgBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          size: const Size(double.infinity, 120),
          painter: _CalmBarChartPainter(t: t),
        ),
      ),
    );
  }
}

class _CalmBarChartPainter extends CustomPainter {
  final AppTokens t;

  _CalmBarChartPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = t.accent
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = t.border
      ..style = PaintingStyle.fill;

    // Draw 4 simple bars representing banking data
    final double barWidth = size.width / 9;
    final double spacing = size.width / 9;

    final data = [40.0, 75.0, 55.0, 95.0];

    for (int i = 0; i < 4; i++) {
      final double left = spacing + i * (barWidth + spacing);
      final double height = (data[i] / 100.0) * size.height;
      final double top = size.height - height;

      // Draw background bar track
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, 0, barWidth, size.height),
          const Radius.circular(4),
        ),
        backgroundPaint,
      );

      // Draw active fill bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
