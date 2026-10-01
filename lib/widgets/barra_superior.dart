// Barra de busca e filtros mostrada acima do mapa.
import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';
import 'logo_aplicativo.dart';
import 'caixa_transparente.dart';

/// Barra de busca flutuante + chips horizontais de filtro (livres no modo visitante).
class TopOverlay extends StatelessWidget {
  const TopOverlay({
    super.key,
    required this.onQuery,
    required this.active,
    required this.onActive,
  });

  final ValueChanged<String> onQuery;
  final AlertCategory? active;
  final ValueChanged<AlertCategory?> onActive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchBar(onQuery: onQuery),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _Chip(
                    label: 'Todas',
                    selected: active == null,
                    color: AppColors.primary,
                    onTap: () => onActive(null),
                  ),
                  for (final c in AlertCategory.values)
                    _Chip(
                      label: c.label,
                      icon: c.icon,
                      selected: active == c,
                      color: c.defaultRisk.color,
                      onTap: () => onActive(active == c ? null : c),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onQuery});

  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 22,
      strong: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const AppLogo.icon(),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onQuery,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Buscar rua, bairro ou ocorrencia',
                hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const Icon(
            Icons.search,
            size: 21,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.22) : AppColors.glass,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.55)
                  : AppColors.glassBorder,
            ),
            boxShadow:
                selected ? AppTheme.glow(color, blur: 18, opacity: 0.35) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: selected ? color : AppColors.muted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.foreground : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
