import 'package:flutter/material.dart';

import '../data/grupos_exemplo.dart';
import '../models/grupo_comunitario.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/caixa_transparente.dart';
import '../widgets/pagina_menu.dart';

/// Lista os grupos comunitários disponíveis.
///
/// Esta tela também mantém o número de filhos do IndexedStack alinhado com as
/// quatro opções do menu lateral, evitando o crash ao abrir Grupos ou Perfil.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPage(
      key: const ValueKey('groups-screen'),
      icon: Icons.groups_outlined,
      title: 'Grupos por perto',
      subtitle: 'Comunidades da sua região para trocar informações',
      child: ListView.separated(
        itemCount: seedGroups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _GroupTile(group: seedGroups[index]),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(group.category.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${group.members}',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.people_outline, size: 17, color: AppColors.muted),
        ],
      ),
    );
  }
}
