import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class CalmPill extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const CalmPill({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final typography = AppTypography.micro(t);

    return Container(
      decoration: BoxDecoration(
        color: color ?? t.accentSoft,
        borderRadius: BorderRadius.circular(999), // radius pill
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: typography.copyWith(
          color: textColor ?? (color != null ? Colors.white : t.accent),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
