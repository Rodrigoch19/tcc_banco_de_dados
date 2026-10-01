// Painel que explica as categorias e os niveis do mapa.
import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';

class LegendContent extends StatelessWidget {
  const LegendContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('NIVEIS DE RISCO'),
        for (final r in RiskLevel.values)
          _Row(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: r.color,
                boxShadow: AppTheme.glow(r.color, blur: 12, opacity: 0.8),
              ),
            ),
            label: r.label,
          ),
        const SizedBox(height: 24),
        const _SectionTitle('CATEGORIAS DE ALERTA'),
        for (final c in AlertCategory.values)
          _Row(
            leading: Icon(
              c.icon,
              size: 19,
              color: c.defaultRisk.color,
            ),
            label: c.label,
          ),
        const SizedBox(height: 20),
        const Text(
          'Marcadores agrupam-se automaticamente conforme o zoom. Alertas confirmados por mais vizinhos aparecem com brilho mais intenso no mapa.',
          style: TextStyle(fontSize: 11.5, height: 1.6, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: AppColors.muted,
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.leading, required this.label});
  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
