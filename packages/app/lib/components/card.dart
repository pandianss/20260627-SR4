import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class CalmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;

  const CalmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(14), // radius lg
        border: hasBorder
            ? Border.all(
                color: t.border,
                width: 1.0,
              )
            : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
