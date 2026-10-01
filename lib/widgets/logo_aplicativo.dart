// Logo reutilizada nas telas do aplicativo.
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 160,
    this.height = 126,
  }) : iconOnly = false;

  const AppLogo.icon({
    super.key,
    double size = 38,
  })  : width = size,
        height = size,
        iconOnly = true;

  static const assetPath = 'assets/images/safeneighbor_logo.jpeg';

  final double width;
  final double height;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo SafeNeighbor',
      image: true,
      child: SizedBox(
        key: const ValueKey('app-logo'),
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(iconOnly ? 12 : 20),
          child: ColoredBox(
            color: const Color(0xFFFDFEFB),
            child: iconOnly
                ? Transform.scale(
                    scale: 1.55,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.15),
                      errorBuilder: _buildFallback,
                    ),
                  )
                : Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: _buildFallback,
                  ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.shield_outlined,
        size: 32,
        color: Color(0xFF05708A),
      ),
    );
  }
}
