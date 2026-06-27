import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Base surface card — white fill, no border, large radius.
class CalmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;
  final double radius;

  const CalmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.fillColor,
    this.radius = 20,
  });

  // ignore: avoid_unused_constructor_parameters
  const CalmCard.bordered({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.fillColor,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: fillColor ?? t.bgSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Coloured fill bento tile — used for paper cards and stat tiles.
class BentoTile extends StatelessWidget {
  final Widget child;
  final Color fillColor;
  final EdgeInsetsGeometry padding;
  final double radius;

  const BentoTile({
    super.key,
    required this.child,
    required this.fillColor,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Small rounded pill — used for card-kind labels, module tags, etc.
class LabelPill extends StatelessWidget {
  final String label;
  final Color? bgColor;
  final Color? textColor;

  const LabelPill(this.label, {super.key, this.bgColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: AppTypography.pill(t).copyWith(
          color: textColor ?? t.ink,
        ),
      ),
    );
  }
}
