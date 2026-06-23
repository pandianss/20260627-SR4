import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum CalmButtonVariant { primary, secondary }

class CalmButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CalmButtonVariant variant;
  final IconData? icon;

  const CalmButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.variant,
    this.icon,
  });

  const CalmButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : variant = CalmButtonVariant.primary;

  const CalmButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : variant = CalmButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final typography = AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500);

    // Minimum tap target height of 44, primary height 48
    final buttonHeight = 48.0;

    final disabled = onPressed == null;

    final Widget label = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: _getTextColor(t, disabled)),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: typography.copyWith(color: _getTextColor(t, disabled)),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: buttonHeight,
        minWidth: 88,
      ),
      child: variant == CalmButtonVariant.primary
          ? TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor: disabled ? t.bgSurface : t.accent,
                disabledBackgroundColor: t.bgSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: label,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: disabled ? t.border : t.borderStrong,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: label,
            ),
    );
  }

  Color _getTextColor(AppTokens t, bool disabled) {
    if (disabled) {
      return t.textTertiary;
    }
    return variant == CalmButtonVariant.primary ? t.onAccent : t.textPrimary;
  }
}
