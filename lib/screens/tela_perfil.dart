// Tela que apresenta e permite editar o perfil.
import 'package:flutter/material.dart';

import '../models/perfil_comunitario.dart';
import '../services/servico_banco_dados.dart';
import '../services/servico_perfil.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/painel_editar_perfil.dart';
import '../widgets/caixa_transparente.dart';
import '../widgets/pagina_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProfileService();
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final profile = service.currentProfile;
        final compact = MediaQuery.sizeOf(context).width < 700;
        return MenuPage(
          key: const ValueKey('profile-screen'),
          icon: Icons.person_outline,
          title: 'Meu perfil',
          subtitle: 'Sua identidade e contribuição na comunidade',
          action: compact
              ? IconButton.filled(
                  key: const ValueKey('edit-profile-button'),
                  onPressed: () => _edit(context, service, profile),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar perfil',
                )
              : FilledButton.tonalIcon(
                  key: const ValueKey('edit-profile-button'),
                  onPressed: () => _edit(context, service, profile),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
          child: ListView(
            children: [
              if (service.isLoading) ...[
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 12),
              ],
              if (service.lastError != null) ...[
                _DatabaseError(
                  message: service.lastError!,
                  onRetry: service.reloadCurrentProfile,
                ),
                const SizedBox(height: 12),
              ],
              _ProfileHero(profile: profile),
              const SizedBox(height: 14),
              _ProgressCard(profile: profile),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Apelidos comunitários',
                subtitle:
                    'Novos apelidos são liberados conforme você contribui.',
              ),
              const SizedBox(height: 12),
              _TitleSelector(profile: profile, service: service),
              const SizedBox(height: 24),
              const _SectionTitle(
                title: 'Suas contribuições',
                subtitle: 'Ações que ajudam sua vizinhança a evoluir.',
              ),
              const SizedBox(height: 12),
              _ContributionStats(profile: profile),
              const SizedBox(height: 24),
              const _SectionTitle(
                title: 'Selos de reconhecimento',
                subtitle: 'Conquistas liberadas pela sua participação.',
              ),
              const SizedBox(height: 12),
              _Badges(profile: profile),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    ProfileService service,
    CommunityProfile profile,
  ) async {
    final result = await EditProfileSheet.show(context, profile: profile);
    if (result == null || !context.mounted) return;
    try {
      await service.updateCurrentProfile(
        name: result.name,
        about: result.about,
      );
    } on DatabaseException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      return;
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF06B6D4)],
              ),
              boxShadow:
                  AppTheme.glow(AppColors.primary, blur: 20, opacity: 0.30),
            ),
            child: Text(
              _initials(profile.displayName),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  key: const ValueKey('profile-display-name'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.selectedTitle.icon,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.selectedTitle.label,
                        key: const ValueKey('selected-community-title'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.email,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.about,
                  key: const ValueKey('profile-about'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SN';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    final next = profile.nextTitle;
    final currentFloor = profile.unlockedTitles.last.requiredPoints;
    final progress = next == null
        ? 1.0
        : ((profile.points - currentFloor) /
                (next.requiredPoints - currentFloor))
            .clamp(0.0, 1.0);

    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.medium),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  next == null
                      ? 'Nível máximo alcançado'
                      : 'Próximo apelido: ${next.label}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${profile.points} pts',
                key: const ValueKey('profile-points'),
                style: const TextStyle(
                  color: AppColors.medium,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.glass,
              color: AppColors.medium,
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: 8),
            Text(
              'Faltam ${next.requiredPoints - profile.points} pontos para desbloquear.',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleSelector extends StatelessWidget {
  const _TitleSelector({required this.profile, required this.service});

  final CommunityProfile profile;
  final ProfileService service;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final title in communityTitles)
          ChoiceChip(
            avatar: Icon(
              profile.points >= title.requiredPoints
                  ? title.icon
                  : Icons.lock_outline,
              size: 17,
            ),
            label: Text(
              profile.points >= title.requiredPoints
                  ? title.label
                  : '${title.label} - ${title.requiredPoints} pts',
            ),
            selected: profile.selectedTitleId == title.id,
            onSelected: profile.points >= title.requiredPoints
                ? (_) async {
                    try {
                      await service.selectCurrentTitle(title.id);
                    } on DatabaseException catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.message)),
                      );
                    }
                  }
                : null,
          ),
      ],
    );
  }
}

class _ContributionStats extends StatelessWidget {
  const _ContributionStats({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final type in ContributionType.values)
              SizedBox(
                width: width,
                child: _StatCard(
                  type: type,
                  count: profile.contributionCount(type),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.type, required this.count});

  final ContributionType type;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(type.icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            type.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    final earnedIds = profile.earnedBadges.map((badge) => badge.id).toSet();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 430
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final badge in communityBadges)
              SizedBox(
                width: width,
                child: _BadgeCard(
                  badge: badge,
                  earned: earnedIds.contains(badge.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.earned});

  final CommunityBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final color = earned ? AppColors.medium : AppColors.muted;
    return Opacity(
      opacity: earned ? 1 : 0.52,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: earned
              ? AppColors.medium.withValues(alpha: 0.10)
              : AppColors.glass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: earned
                ? AppColors.medium.withValues(alpha: 0.30)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(
                earned ? badge.icon : Icons.lock_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    earned
                        ? badge.description
                        : 'Desbloqueia com ${badge.requiredPoints} pontos',
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _DatabaseError extends StatelessWidget {
  const _DatabaseError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.critical.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.critical),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
