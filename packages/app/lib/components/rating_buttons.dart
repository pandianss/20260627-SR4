import 'package:flutter/material.dart';
import 'package:srs/srs.dart';
import '../theme/tokens.dart';

class CalmRatingButtons extends StatelessWidget {
  final ValueChanged<Rating> onRatingSelected;

  const CalmRatingButtons({
    super.key,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      children: [
        _buildButton(context, Rating.again, 'Again', t.danger, false),
        const SizedBox(width: 8),
        _buildButton(context, Rating.hard, 'Hard', t.warning, false),
        const SizedBox(width: 8),
        // Good is the default/recommended path, highlighted in teal accent
        _buildButton(context, Rating.good, 'Good', t.accent, true),
        const SizedBox(width: 8),
        _buildButton(context, Rating.easy, 'Easy', t.textSecondary, false),
      ],
    );
  }

  Widget _buildButton(BuildContext context, Rating rating, String label, Color color, bool isHighlighted) {
    final t = context.tokens;
    final typography = AppTypography.micro(t).copyWith(fontWeight: FontWeight.w500);

    return Expanded(
      child: GestureDetector(
        onTap: () => onRatingSelected(rating),
        child: Container(
          height: 48, // 44px min tap target
          decoration: BoxDecoration(
            color: isHighlighted ? t.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10), // radius md
            border: Border.all(
              color: isHighlighted ? t.accent : t.border,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: typography.copyWith(
                  color: isHighlighted ? t.accent : t.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              // Subtle colored dot for emphasis
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
