// Painel inferior com a lista de alertas.
import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';
import 'cartao_alerta.dart';
import 'caixa_transparente.dart';
import 'animacao_repetida.dart';

/// Painel inferior arrastavel com 3 estagios: 15%, 42% e 85% da altura.
class AlertsSheet extends StatelessWidget {
  const AlertsSheet({
    super.key,
    required this.controller,
    required this.alerts,
    required this.period,
    required this.onPeriod,
    required this.onNewAlert,
    required this.onFocus,
    required this.onChat,
  });

  final DraggableScrollableController controller;
  final List<CommunityAlert> alerts;
  final String period;
  final ValueChanged<String> onPeriod;
  final VoidCallback onNewAlert;
  final ValueChanged<CommunityAlert> onFocus;
  final ValueChanged<CommunityAlert> onChat;

  RiskLevel get _status {
    if (alerts.any((a) => a.risk == RiskLevel.critico)) {
      return RiskLevel.critico;
    }
    if (alerts.any((a) => a.risk == RiskLevel.medio)) {
      return RiskLevel.medio;
    }
    return RiskLevel.seguro;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.42, 0.85],
      builder: (context, scrollController) {
        return GlassContainer(
          radius: 28,
          strong: true,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  LoopAnimation(
                    duration: const Duration(milliseconds: 700),
                    reverse: true,
                    enabled: status == RiskLevel.critico,
                    builder: (context, progress, child) => Opacity(
                      opacity: 1 - 0.8 * Curves.easeInOut.transform(progress),
                      child: child,
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status.color,
                        boxShadow:
                            AppTheme.glow(status.color, blur: 12, opacity: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua regiao esta em nivel ${status.label.toLowerCase()}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${alerts.length} alertas nas ultimas ${period == "24h" ? "24 horas" : "7 dias"}',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _PeriodToggle(period: period, onPeriod: onPeriod),
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 46,
                    child: IconButton.filled(
                      onPressed: onNewAlert,
                      tooltip: 'Novo alerta',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.critical,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_location_alt_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (alerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Nenhum alerta com os filtros atuais.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                  ),
                )
              else
                for (final a in alerts)
                  AlertCard(
                    alert: a,
                    onFocus: () => onFocus(a),
                    onChat: () => onChat(a),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onPeriod});

  final String period;
  final ValueChanged<String> onPeriod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final p in const ['24h', '7d'])
            GestureDetector(
              onTap: () => onPeriod(p),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: period == p
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: period == p ? AppColors.foreground : AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
