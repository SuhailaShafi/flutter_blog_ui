import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> colors;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = AppTheme.primaryGradient,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? LinearGradient(
                  colors: colors.map((c) => c.withValues(alpha: 0.5)).toList())
              : LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        ),
      ),
    );
  }
}
