// Tela que junta o mapa, os filtros e a lista de alertas.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/alerta.dart';
import '../widgets/mapa_alertas.dart';
import '../widgets/painel_alertas.dart';
import '../widgets/barra_superior.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.alerts,
    required this.mapController,
    required this.sheetController,
    required this.loadTiles,
    required this.period,
    required this.activeFilter,
    required this.onQuery,
    required this.onFilter,
    required this.onPeriod,
    required this.onNewAlert,
    required this.onSelect,
    required this.onFocus,
    required this.onChat,
  });

  final List<CommunityAlert> alerts;
  final MapController mapController;
  final DraggableScrollableController sheetController;
  final bool loadTiles;
  final String period;
  final AlertCategory? activeFilter;
  final ValueChanged<String> onQuery;
  final ValueChanged<AlertCategory?> onFilter;
  final ValueChanged<String> onPeriod;
  final VoidCallback onNewAlert;
  final ValueChanged<CommunityAlert> onSelect;
  final ValueChanged<CommunityAlert> onFocus;
  final ValueChanged<CommunityAlert> onChat;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('map-screen'),
      children: [
        Positioned.fill(
          child: AlertMap(
            alerts: alerts,
            controller: mapController,
            loadTiles: loadTiles,
            onSelect: onSelect,
          ),
        ),
        IgnorePointer(
          child: Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xD907090F), Colors.transparent],
              ),
            ),
          ),
        ),
        TopOverlay(
          onQuery: onQuery,
          active: activeFilter,
          onActive: onFilter,
        ),
        AlertsSheet(
          controller: sheetController,
          alerts: alerts,
          period: period,
          onPeriod: onPeriod,
          onNewAlert: onNewAlert,
          onFocus: onFocus,
          onChat: onChat,
        ),
      ],
    );
  }
}
