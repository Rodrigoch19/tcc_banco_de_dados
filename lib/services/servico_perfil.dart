// Guarda o perfil localmente e o sincroniza com o Firebase quando disponível.
import 'package:flutter/foundation.dart';

import '../models/perfil_comunitario.dart';
import 'servico_banco_dados.dart';

class ProfileService extends ChangeNotifier {
  factory ProfileService() => _instance;

  ProfileService._();

  static final ProfileService _instance = ProfileService._();
  static const _defaultEmail = 'vizinho@safeneighbor.local';
  static const _defaultName = 'Vizinho';

  final DatabaseService _database = DatabaseService();
  CommunityProfile _profile = const CommunityProfile(
    email: _defaultEmail,
    displayName: _defaultName,
  );
  bool _isLoading = false;
  String? _lastError;
  String? _activeUserId;

  CommunityProfile get currentProfile => _profile;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> updateCurrentProfile({
    required String name,
    required String about,
  }) async {
    final normalizedName = name.trim();
    final normalizedAbout = about.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Informe um nome.');
    }
    if (normalizedAbout.isEmpty) {
      throw ArgumentError.value(about, 'about', 'Conte um pouco sobre você.');
    }

    await _save(
      _profile.copyWith(
        displayName: normalizedName,
        about: normalizedAbout,
      ),
    );
  }

  Future<void> selectCurrentTitle(String titleId) async {
    final title = _titleById(titleId);

    if (_profile.points < title.requiredPoints) {
      throw StateError('Este título ainda não foi desbloqueado.');
    }
    if (_profile.selectedTitleId == title.id) return;

    await _save(_profile.copyWith(selectedTitleId: title.id));
  }

  Future<void> addCurrentContribution(ContributionType type) async {
    var updated = _profile;

    if (type == ContributionType.alertPublished) {
      updated = _profile.copyWith(
        points: _profile.points + type.points,
        alertsPublished: _profile.alertsPublished + 1,
      );
    } else if (type == ContributionType.groupJoined) {
      updated = _profile.copyWith(
        points: _profile.points + type.points,
        groupsJoined: _profile.groupsJoined + 1,
      );
    } else if (type == ContributionType.groupCreated) {
      updated = _profile.copyWith(
        points: _profile.points + type.points,
        groupsCreated: _profile.groupsCreated + 1,
      );
    } else {
      updated = _profile.copyWith(
        points: _profile.points + type.points,
        messagesSent: _profile.messagesSent + 1,
      );
    }

    await _save(updated);
  }

  Future<void> reloadCurrentProfile() => _loadProfile();

  void clearCurrentProfile() {
    _profile = const CommunityProfile(
      email: _defaultEmail,
      displayName: _defaultName,
    );
    _activeUserId = null;
    _lastError = null;
    notifyListeners();
  }

  Future<void> loadCurrentUserProfile() async {
    final user = _database.currentUser;
    if (user == null) return;

    if (_activeUserId != user.uid) {
      _activeUserId = user.uid;
      _profile = CommunityProfile(
        email: user.email?.trim().toLowerCase() ?? _defaultEmail,
        displayName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : _defaultName,
      );
      notifyListeners();
    }
    await _loadProfile();
  }

  @visibleForTesting
  void resetForTests({
    String displayName = _defaultName,
    String email = _defaultEmail,
  }) {
    _profile = CommunityProfile(email: email, displayName: displayName);
    _isLoading = false;
    _lastError = null;
    _activeUserId = null;
    notifyListeners();
  }

  CommunityTitle _titleById(String titleId) {
    for (final title in communityTitles) {
      if (title.id == titleId) return title;
    }
    throw ArgumentError.value(titleId, 'titleId', 'Título desconhecido.');
  }

  Future<void> _save(CommunityProfile profile) async {
    final previous = _profile;
    _profile = profile;
    _lastError = null;
    notifyListeners();

    try {
      await _database.saveProfile(profile: profile);
    } on DatabaseException catch (error) {
      _profile = previous;
      _lastError = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadProfile() async {
    if (_isLoading || !_database.isAvailable) return;

    _isLoading = true;
    final loadingUserId = _activeUserId;
    _lastError = null;
    notifyListeners();
    try {
      final profile = await _database.getOrCreateProfile(
        email: _profile.email,
        displayName: _profile.displayName,
      );
      if (_activeUserId == loadingUserId) _profile = profile;
    } on DatabaseException catch (error) {
      _lastError = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
