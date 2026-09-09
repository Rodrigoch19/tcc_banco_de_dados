// Menu usado para trocar de pagina.
import 'package:flutter/material.dart';

import '../theme/tema_aplicativo.dart';
import 'logo_aplicativo.dart';

enum MenuTab { chat, mapa, grupos, perfil }

class _MenuItem {
  const _MenuItem(this.tab, this.label, this.icon);

  final MenuTab tab;
  final String label;
  final IconData icon;
}

const _items = [
  _MenuItem(MenuTab.chat, 'Chat', Icons.chat_bubble_outline),
  _MenuItem(MenuTab.mapa, 'Mapa', Icons.map_outlined),
  _MenuItem(MenuTab.grupos, 'Grupos', Icons.groups_outlined),
  _MenuItem(MenuTab.perfil, 'Perfil', Icons.person_outline),
];

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.active,
    required this.onChange,
    this.onLogout,
    this.isLoggingOut = false,
  });

  final MenuTab active;
  final ValueChanged<MenuTab> onChange;
  final VoidCallback? onLogout;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return AnimatedContainer(
      key: const ValueKey('side-menu'),
      duration: const Duration(milliseconds: 220),
      width: compact ? 76 : 176,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            children: [
              _Brand(compact: compact),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1, color: AppColors.glassBorder),
              ),
              for (final item in _items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MenuButton(
                    label: item.label,
                    icon: item.icon,
                    selected: active == item.tab,
                    compact: compact,
                    onTap: () => onChange(item.tab),
                  ),
                ),
              if (onLogout != null) ...[
                const Spacer(),
                _MenuButton(
                  label: isLoggingOut ? 'Saindo...' : 'Sair',
                  icon: Icons.logout,
                  selected: false,
                  compact: compact,
                  onTap: isLoggingOut ? null : onLogout,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppLogo.icon(size: 42),
        if (!compact) ...[
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SafeNeighbor',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.foreground : AppColors.muted;
    return Tooltip(
      message: compact ? label : '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.42)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  compact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, size: 21, color: color),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
