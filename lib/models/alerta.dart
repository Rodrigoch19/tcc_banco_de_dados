// Classes que guardam os dados de um alerta.
import 'package:flutter/material.dart';
import '../theme/tema_aplicativo.dart';

enum RiskLevel {
  critico('Critico', AppColors.critical),
  medio('Medio', AppColors.medium),
  seguro('Seguro', AppColors.safe);

  const RiskLevel(this.label, this.color);

  final String label;
  final Color color;
}

enum AlertCategory {
  suspeito('Suspeito', Icons.visibility_outlined, RiskLevel.medio),
  assalto('Assalto', Icons.warning_amber_rounded, RiskLevel.critico),
  iluminacao('Iluminacao', Icons.lightbulb_outline, RiskLevel.medio),
  animais('Animais', Icons.pets_outlined, RiskLevel.medio),
  segura('Area Segura', Icons.verified_user_outlined, RiskLevel.seguro);

  const AlertCategory(this.label, this.icon, this.defaultRisk);

  final String label;
  final IconData icon;
  final RiskLevel defaultRisk;
}

class CommunityAlert {
  const CommunityAlert({
    required this.id,
    required this.category,
    required this.risk,
    required this.title,
    required this.description,
    required this.street,
    required this.lat,
    required this.lng,
    required this.minutesAgo,
    this.distanceKm,
    required this.author,
    required this.confirmations,
  });

  final String id;
  final AlertCategory category;
  final RiskLevel risk;
  final String title;
  final String description;
  final String street;
  final double lat;
  final double lng;
  final int minutesAgo;
  final double? distanceKm;
  final String author;
  final int confirmations;

  String get timeAgo {
    if (minutesAgo < 60) return 'ha $minutesAgo min';
    if (minutesAgo < 1440) return 'ha ${(minutesAgo / 60).floor()} h';
    return 'ha ${(minutesAgo / 1440).floor()} d';
  }

  String get distanceLabel {
    final distance = distanceKm;
    if (distance == null) return 'calculando distancia';
    if (distance < 0) return 'distancia indisponivel';
    if (distance < 1) return '${(distance * 1000).round()} m';
    return '${distance.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  CommunityAlert withDistance(double distanceKm) {
    return CommunityAlert(
      id: id,
      category: category,
      risk: risk,
      title: title,
      description: description,
      street: street,
      lat: lat,
      lng: lng,
      minutesAgo: minutesAgo,
      distanceKm: distanceKm,
      author: author,
      confirmations: confirmations,
    );
  }
}
