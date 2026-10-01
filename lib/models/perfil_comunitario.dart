// Classes que guardam os dados do perfil da pessoa usuaria.
import 'package:flutter/material.dart';

const defaultCommunityAbout =
    'Acredito que uma vizinhança mais segura começa com informação, cuidado e colaboração. Gosto de ajudar e fortalecer quem vive por perto.';

enum ContributionType {
  alertPublished(20, 'Alerta publicado', Icons.campaign_outlined),
  groupJoined(10, 'Entrada em grupo', Icons.group_add_outlined),
  groupCreated(25, 'Grupo criado', Icons.groups_2_outlined),
  messageSent(2, 'Mensagem enviada', Icons.chat_bubble_outline_rounded);

  const ContributionType(this.points, this.label, this.icon);

  final int points;
  final String label;
  final IconData icon;
}

@immutable
class CommunityBadge {
  const CommunityBadge({
    required this.id,
    required this.label,
    required this.description,
    required this.requiredPoints,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final int requiredPoints;
  final IconData icon;
}

const communityBadges = <CommunityBadge>[
  CommunityBadge(
    id: 'boas-vindas',
    label: 'Boas-vindas',
    description: 'Começou a fazer parte da vizinhança.',
    requiredPoints: 0,
    icon: Icons.favorite_border_rounded,
  ),
  CommunityBadge(
    id: 'primeira-contribuicao',
    label: 'Primeira contribuição',
    description: 'Deu os primeiros passos para ajudar a comunidade.',
    requiredPoints: 5,
    icon: Icons.volunteer_activism_outlined,
  ),
  CommunityBadge(
    id: 'olhar-atento',
    label: 'Olhar atento',
    description: 'Ajudou a manter os vizinhos bem informados.',
    requiredPoints: 20,
    icon: Icons.remove_red_eye_outlined,
  ),
];

@immutable
class CommunityProfile {
  const CommunityProfile({
    required this.email,
    required this.displayName,
    this.about = defaultCommunityAbout,
    this.points = 0,
    this.alertsPublished = 0,
    this.groupsJoined = 0,
    this.groupsCreated = 0,
    this.messagesSent = 0,
  });

  final String email;
  final String displayName;
  final String about;
  final int points;
  final int alertsPublished;
  final int groupsJoined;
  final int groupsCreated;
  final int messagesSent;

  factory CommunityProfile.fromMap(Map<String, dynamic> data) {
    int number(String key) => (data[key] as num?)?.toInt() ?? 0;
    return CommunityProfile(
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Vizinho',
      about: data['about'] as String? ?? defaultCommunityAbout,
      points: number('points'),
      alertsPublished: number('alertsPublished'),
      groupsJoined: number('groupsJoined'),
      groupsCreated: number('groupsCreated'),
      messagesSent: number('messagesSent'),
    );
  }

  Map<String, Object> toMap() => {
        'email': email,
        'displayName': displayName,
        'about': about,
        'points': points,
        'alertsPublished': alertsPublished,
        'groupsJoined': groupsJoined,
        'groupsCreated': groupsCreated,
        'messagesSent': messagesSent,
      };

  List<CommunityBadge> get earnedBadges {
    final badges = <CommunityBadge>[];

    for (final badge in communityBadges) {
      if (points >= badge.requiredPoints) {
        badges.add(badge);
      }
    }

    return badges;
  }

  int contributionCount(ContributionType type) {
    if (type == ContributionType.alertPublished) {
      return alertsPublished;
    }
    if (type == ContributionType.groupJoined) {
      return groupsJoined;
    }
    if (type == ContributionType.groupCreated) {
      return groupsCreated;
    }
    return messagesSent;
  }

  CommunityProfile copyWith({
    String? email,
    String? displayName,
    String? about,
    int? points,
    int? alertsPublished,
    int? groupsJoined,
    int? groupsCreated,
    int? messagesSent,
  }) {
    return CommunityProfile(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      about: about ?? this.about,
      points: points ?? this.points,
      alertsPublished: alertsPublished ?? this.alertsPublished,
      groupsJoined: groupsJoined ?? this.groupsJoined,
      groupsCreated: groupsCreated ?? this.groupsCreated,
      messagesSent: messagesSent ?? this.messagesSent,
    );
  }
}
