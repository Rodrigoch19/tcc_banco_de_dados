// Mapa com os marcadores dos alertas.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/alertas_exemplo.dart';
import '../models/alerta.dart';
import '../theme/tema_aplicativo.dart';
import 'animacao_repetida.dart';

/// Mapa escuro em tela cheia com marcadores neon por nivel de risco.
class AlertMap extends StatelessWidget {
  const AlertMap({
    super.key,
    required this.alerts,
    required this.controller,
    required this.onSelect,
    this.loadTiles = true,
  });

  final List<CommunityAlert> alerts;
  final MapController controller;
  final ValueChanged<CommunityAlert> onSelect;
  final bool loadTiles;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: const MapOptions(
        initialCenter: cityCenter,
        initialZoom: 14.5,
        minZoom: 11,
        maxZoom: 18,
        backgroundColor: AppColors.background,
      ),
      children: [
        if (loadTiles)
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'app.safeneighbor',
            retinaMode: RetinaMode.isHighDensity(context),
          ),
        LoopAnimation(
          duration: const Duration(milliseconds: 2200),
          enabled: alerts.isNotEmpty,
          builder: (context, progress, child) => CircleLayer(
            circles: [
              for (final a in alerts)
                CircleMarker(
                  point: LatLng(a.lat, a.lng),
                  radius: (a.risk == RiskLevel.critico ? 70 : 48) *
                      (0.7 + 0.55 * progress),
                  useRadiusInMeter: false,
                  color: a.risk.color.withValues(alpha: 0.14 * (1 - progress)),
                  borderColor:
                      a.risk.color.withValues(alpha: 0.32 * (1 - progress)),
                  borderStrokeWidth: 1,
                ),
            ],
          ),
        ),
        MarkerLayer(
          markers: [
            for (final a in alerts)
              Marker(
                point: LatLng(a.lat, a.lng),
                width: 46,
                height: 46,
                child: _AlertMarker(alert: a, onTap: () => onSelect(a)),
              ),
          ],
        ),
      ],
    );
  }
}

class _AlertMarker extends StatelessWidget {
  const _AlertMarker({required this.alert, required this.onTap});

  final CommunityAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = alert.risk.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0D1119),
          border: Border.all(color: color, width: 2),
          boxShadow: AppTheme.glow(color, blur: 20, opacity: 0.6),
        ),
        child: Center(
          child: Icon(
            alert.category.icon,
            size: 21,
            color: color,
          ),
        ),
      ),
    );
  }
}
