// Tela que lista as conversas ligadas aos alertas.
import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/caixa_transparente.dart';
import '../widgets/pagina_menu.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.alerts,
    required this.onOpen,
  });

  final List<CommunityAlert> alerts;
  final ValueChanged<CommunityAlert> onOpen;

  @override
  Widget build(BuildContext context) {
    return MenuPage(
      key: const ValueKey('chat-screen'),
      icon: Icons.chat_bubble_outline,
      title: 'Chat da vizinhanca',
      subtitle: 'Conversas relacionadas aos alertas perto de voce',
      child: alerts.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma conversa disponivel.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final alert = alerts[index];
                return _ConversationTile(
                  alert: alert,
                  onTap: () => onOpen(alert),
                );
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.alert, required this.onTap});

  final CommunityAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = alert.risk.color;
    return Semantics(
      button: true,
      label: 'Abrir chat sobre ${alert.title}',
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          radius: 20,
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(alert.category.icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alert.author} - ${alert.street}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                alert.timeAgo,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
