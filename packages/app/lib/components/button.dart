import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum CalmButtonVariant { primary, secondary, ghost }

/// Pill-shaped button following the editorial redesign.
/// Primary → ink fill (#1A1A1A), white text, fully pill-shaped.
/// Secondary → sage green fill, dark text.
/// Ghost → transparent fill, ink border.
class CalmButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CalmButtonVariant variant;
  final IconData? icon;
  final bool expand;

  const CalmButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.variant,
    this.icon,
    this.expand = true,
  });

  const CalmButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expand = true,
  }) : variant = CalmButtonVariant.primary;

  const CalmButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expand = true,
  }) : variant = CalmButtonVariant.secondary;

  const CalmButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expand = true,
  }) : variant = CalmButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = onPressed == null;

    final Color bgColor;
    final Color fgColor;
    final Border? border;

    switch (variant) {
      case CalmButtonVariant.primary:
        bgColor = disabled ? t.border : t.ink;
        fgColor = disabled ? t.textTertiary : t.onInk;
        border = null;
      case CalmButtonVariant.secondary:
        bgColor = disabled ? t.border : t.sage;
        fgColor = disabled ? t.textTertiary : t.ink;
        border = null;
      case CalmButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = disabled ? t.textTertiary : t.textPrimary;
        border = Border.all(color: disabled ? t.border : t.borderStrong, width: 1.5);
    }

    final label = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 7),
        ],
        Text(
          text,
          style: AppTypography.heading(t).copyWith(
            color: fgColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );

    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: border != null
                ? BorderSide(color: disabled ? t.border : t.borderStrong, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: label,
      ),
    );
  }
}
