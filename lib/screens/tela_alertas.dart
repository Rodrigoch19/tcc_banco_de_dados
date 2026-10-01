import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/cartao_alerta.dart';
import '../widgets/pagina_menu.dart';
class AlertsScreen extends StatelessWidget { const AlertsScreen({super.key, required this.alerts, required this.onFocus, required this.onChat}); final List<CommunityAlert> alerts; final ValueChanged<CommunityAlert> onFocus; final VoidCallback onChat; @override Widget build(BuildContext context) => MenuPage(key: const ValueKey('alerts-screen'), icon: Icons.notifications_active_outlined, title: 'Alertas', subtitle: 'Acompanhe os avisos recentes da sua vizinhanca', child: alerts.isEmpty ? const Center(child: Text('Nenhum alerta com os filtros atuais.', style: TextStyle(color: AppColors.muted))) : ListView.builder(itemCount: alerts.length, itemBuilder: (_, i) => AlertCard(alert: alerts[i], onFocus: () => onFocus(alerts[i]), onChat: onChat))); }
