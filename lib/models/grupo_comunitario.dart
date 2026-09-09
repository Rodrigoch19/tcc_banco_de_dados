// Classes que guardam os dados de grupos e mensagens.
import 'package:flutter/material.dart';

enum GroupCategory {
  seguranca('Segurança', Icons.shield_outlined),
  vizinhanca('Vizinhança', Icons.groups_2_outlined),
  mobilidade('Mobilidade', Icons.route_outlined),
  animais('Animais', Icons.pets_outlined),
  familias('Famílias', Icons.family_restroom_outlined),
  lazer('Lazer', Icons.sports_soccer_outlined);

  const GroupCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

@immutable
class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.lat,
    required this.lng,
    required this.members,
    required this.initialMessages,
  });

  final String id;
  final String name;
  final String description;
  final GroupCategory category;
  final double lat;
  final double lng;
  final int members;
  final List<GroupMessage> initialMessages;

  CommunityGroup copyWith({
    String? id,
    String? name,
    String? description,
    GroupCategory? category,
    double? lat,
    double? lng,
    int? members,
    List<GroupMessage>? initialMessages,
  }) {
    return CommunityGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      members: members ?? this.members,
      initialMessages: initialMessages ?? this.initialMessages,
    );
  }
}

@immutable
class GroupMessage {
  const GroupMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.sentAt,
    this.isMine = false,
  });

  final String id;
  final String author;
  final String text;
  final String sentAt;
  final bool isMine;
}
