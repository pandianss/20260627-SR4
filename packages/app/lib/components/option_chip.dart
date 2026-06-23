import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum OptionChipState { unselected, selected, correct, wrong }

class CalmOptionChip extends StatelessWidget {
  final String label;
  final String identifier; // e.g. "A", "B", "C", "D"
  final OptionChipState state;
  final VoidCallback? onTap;

  const CalmOptionChip({
    super.key,
    required this.label,
    required this.identifier,
    this.state = OptionChipState.unselected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final typography = AppTypography.body(t);

    final isTappable = onTap != null;

    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 48, // min tap target is 44, chip height 48
        ),
        decoration: BoxDecoration(
          color: _getBgColor(t),
          borderRadius: BorderRadius.circular(10), // radius md
          border: Border.all(
            color: _getBorderColor(t),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // Option identifier (e.g., "A")
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getIdentifierBgColor(t),
              ),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Text(
                identifier,
                style: AppTypography.body(t).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: _getIdentifierTextColor(t),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Text Label
            Expanded(
              child: Text(
                label,
                style: typography.copyWith(
                  color: _getTextColor(t),
                ),
              ),
            ),
            // Trailing icon indicator (accessibility check: color-blind safe icon)
            if (state != OptionChipState.unselected) ...[
              const SizedBox(width: 8),
              Icon(
                _getIconData(),
                size: 20,
                color: _getIconColor(t),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBgColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => Colors.transparent,
        OptionChipState.selected => t.accentSoft,
        OptionChipState.correct => t.accentSoft,
        OptionChipState.wrong => t.danger.withOpacity(0.08),
      };

  Color _getBorderColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => t.border,
        OptionChipState.selected => t.accent,
        OptionChipState.correct => t.accent,
        OptionChipState.wrong => t.danger,
      };

  Color _getIdentifierBgColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => t.border,
        OptionChipState.selected => t.accent,
        OptionChipState.correct => t.accent,
        OptionChipState.wrong => t.danger,
      };

  Color _getIdentifierTextColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => t.textSecondary,
        OptionChipState.selected => t.onAccent,
        OptionChipState.correct => t.onAccent,
        OptionChipState.wrong => t.onAccent,
      };

  Color _getTextColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => t.textPrimary,
        OptionChipState.selected => t.textPrimary,
        OptionChipState.correct => t.textPrimary,
        OptionChipState.wrong => t.textPrimary,
      };

  Color _getIconColor(AppTokens t) => switch (state) {
        OptionChipState.unselected => Colors.transparent,
        OptionChipState.selected => t.accent,
        OptionChipState.correct => t.accent,
        OptionChipState.wrong => t.danger,
      };

  IconData _getIconData() => switch (state) {
        OptionChipState.unselected => Icons.circle_outlined,
        OptionChipState.selected => Icons.check_circle_outline,
        OptionChipState.correct => Icons.check_circle,
        OptionChipState.wrong => Icons.cancel,
      };
}
