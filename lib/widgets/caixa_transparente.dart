// Caixa visual reutilizavel com fundo transparente.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/tema_aplicativo.dart';

/// Container com efeito glassmorphism reutilizado em toda a interface.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.strong = false,
    this.blur = 22,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool strong;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: strong ? const Color(0xE60D1119) : AppColors.glass,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
