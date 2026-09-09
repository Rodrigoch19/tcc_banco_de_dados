// Tela principal: guarda o estado e liga as outras telas do aplicativo.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/alertas_exemplo.dart';
import '../models/alerta.dart';
import '../models/perfil_comunitario.dart';
import '../services/servico_autenticacao.dart';
import '../services/servico_banco_dados.dart';
import '../services/servico_localizacao.dart';
import '../services/servico_perfil.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/painel_autenticacao.dart';
import '../widgets/painel_novo_alerta.dart';
import '../widgets/menu_lateral.dart';
import 'tela_conversas.dart';
import 'tela_grupos.dart';
import 'tela_mapa.dart';
import 'tela_perfil.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key, this.carregarMapa = true});

  final bool carregarMapa;

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _mapController = MapController();
  final _sheetController = DraggableScrollableController();
  final _profileService = ProfileService();
  StreamSubscription<DeviceCoordinates>? _locationSubscription;

  final List<CommunityAlert> _alerts = List.of(seedAlerts);
  DeviceCoordinates? _deviceCoordinates;
  bool _distanceUnavailable = false;
  String _query = '';
  AlertCategory? _filter;
  String _period = '24h';
  MenuTab _tab = MenuTab.mapa;
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await AuthService().logout();
      _profileService.clearCurrentProfile();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => TelaInicial(carregarMapa: widget.carregarMapa),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      _toast('Não foi possível sair. Tente novamente.');
    }
  }

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_onProfileChanged);
    unawaited(_profileService.loadCurrentUserProfile());
    _locationSubscription = DeviceLocationService.watchCoordinates().listen(
      (location) {
        if (!mounted) return;
        setState(() {
          _deviceCoordinates = location;
          _distanceUnavailable = false;
        });
      },
      onError: (_) {
        if (mounted) setState(() => _distanceUnavailable = true);
      },
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _profileService.removeListener(_onProfileChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  List<CommunityAlert> get _visible {
    final maxMinutes = _period == '24h' ? 1440 : 10080;
    final search = _query.trim().toLowerCase();
    final visibleAlerts = <CommunityAlert>[];

    for (final alert in _alerts) {
      final text =
          '${alert.title} ${alert.street} ${alert.description}'.toLowerCase();
      final matchesCategory = _filter == null || alert.category == _filter;
      final matchesSearch = search.isEmpty || text.contains(search);
      final matchesPeriod = alert.minutesAgo <= maxMinutes;

      if (matchesCategory && matchesSearch && matchesPeriod) {
        visibleAlerts.add(_addRealDistance(alert));
      }
    }

    return visibleAlerts;
  }

  CommunityAlert _addRealDistance(CommunityAlert alert) {
    final location = _deviceCoordinates;
    if (location == null) {
      return _distanceUnavailable ? alert.withDistance(-1) : alert;
    }
    return alert.withDistance(
      DeviceLocationService.distanceInKm(location, alert.lat, alert.lng),
    );
  }

  void _snap(double size) {
    _sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
      ),
    );
  }

  Future<void> _openNewAlert() async {
    final result = await NewAlertSheet.show(context);
    if (result == null || !mounted) return;

    final newAlert = CommunityAlert(
      id: 'n${DateTime.now().millisecondsSinceEpoch}',
      category: result.category,
      risk: result.risk,
      title: result.category.label,
      description: result.description.isEmpty
          ? 'Relato enviado pela comunidade.'
          : result.description,
      street: result.location.address,
      lat: result.location.latitude,
      lng: result.location.longitude,
      minutesAgo: 1,
      author: 'Voce',
      confirmations: 1,
    );

    setState(() {
      _deviceCoordinates = result.location;
      _alerts.insert(0, newAlert);
    });
    _snap(0.42);
    await _addContribution(ContributionType.alertPublished);
    _toast('Alerta publicado para a vizinhanca');
  }

  void _onTab(MenuTab tab) {
    if (tab == MenuTab.mapa) {
      setState(() => _tab = tab);
      _snap(0.15);
      _mapController.move(cityCenter, 14.5);
      return;
    }

    if (tab == MenuTab.chat) {
      _openProtectedTab(
        tab,
        reason: 'Converse no chat comunitário do seu bairro.',
        message: 'Chat da vizinhanca aberto',
      );
      return;
    }

    if (tab == MenuTab.grupos) {
      _openProtectedTab(
        tab,
        reason: 'Entre nos grupos da sua vizinhança.',
        message: 'Grupos da vizinhanca abertos',
      );
      return;
    }

    _openProtectedTab(
      tab,
      reason: 'Seu perfil guarda suas contribuições e conquistas.',
      message: 'Perfil aberto',
    );
  }

  Future<void> _openProtectedTab(
    MenuTab tab, {
    required String reason,
    required String message,
  }) async {
    await _requireAuth(reason, () {
      _openTab(tab, message: message);
    });
  }

  Future<void> _requireAuth(
    String reason,
    FutureOr<void> Function() onAuthenticated,
  ) async {
    final auth = AuthService();
    if (auth.isAvailable && auth.currentUser == null) {
      final loggedIn = await AuthSheet.show(context, reason: reason);
      if (loggedIn != true || !mounted) return;
      await _profileService.loadCurrentUserProfile();
      if (!mounted) return;
    }
    await onAuthenticated();
  }

  void _openTab(
    MenuTab tab, {
    required String message,
    VoidCallback? onOpen,
  }) {
    setState(() => _tab = tab);
    if (onOpen != null) {
      onOpen();
    }
    _toast(message);
  }

  int _tabIndex() {
    if (_tab == MenuTab.chat) return 1;
    if (_tab == MenuTab.grupos) return 2;
    if (_tab == MenuTab.perfil) return 3;
    return 0;
  }

  void _focusAlert(CommunityAlert alert, [double? sheetSize]) {
    _mapController.move(LatLng(alert.lat, alert.lng), 16);
    if (sheetSize != null) _snap(sheetSize);
  }

  void _openAlertChat(CommunityAlert alert) {
    _requireAuth(
      'Converse no chat comunitário do seu bairro.',
      () => _toast('Chat aberto: ${alert.title}'),
    );
  }

  Future<void> _addContribution(ContributionType type) async {
    try {
      await _profileService.addCurrentContribution(type);
    } on DatabaseException catch (error) {
      if (mounted) _toast(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SideMenu(
            active: _tab,
            onChange: _onTab,
            onLogout: AuthService().currentUser != null ? _logout : null,
            isLoggingOut: _isLoggingOut,
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex(),
              children: [
                MapScreen(
                  alerts: visible,
                  mapController: _mapController,
                  sheetController: _sheetController,
                  loadTiles: widget.carregarMapa,
                  period: _period,
                  activeFilter: _filter,
                  onQuery: (v) => setState(() => _query = v),
                  onFilter: (v) => setState(() => _filter = v),
                  onPeriod: (p) => setState(() => _period = p),
                  onNewAlert: () => _requireAuth(
                    'Envie alertas em tempo real para os vizinhos.',
                    _openNewAlert,
                  ),
                  onSelect: (a) => _focusAlert(a, 0.42),
                  onFocus: _focusAlert,
                  onChat: _openAlertChat,
                ),
                ChatScreen(
                  alerts: visible,
                  onOpen: _openAlertChat,
                ),
                const GroupsScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
