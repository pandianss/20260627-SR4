import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/tokens.dart';

class ShimmerLogo extends StatefulWidget {
  final double size;
  const ShimmerLogo({super.key, this.size = 80});

  @override
  State<ShimmerLogo> createState() => _ShimmerLogoState();
}

class _ShimmerLogoState extends State<ShimmerLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _controller.repeat();
    } else {
      _controller.value = 0.5; // static position for widget tests
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // In dark mode, white highlights look great. 
    // In light mode, a slightly off-white highlight works best.
    final highlightColor = isDark ? Colors.white : const Color(0xFFE8F5E9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                t.accent,
                highlightColor,
                t.accent,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: SvgPicture.asset(
            'assets/logo.svg',
            width: widget.size,
            height: widget.size,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double w = bounds.width;
    final double h = bounds.height;
    // Slide gradient horizontally across the bounds
    return Matrix4.translationValues(
      -w + (slidePercent * 2 * w),
      -h + (slidePercent * 2 * h),
      0,
    );
  }
}
