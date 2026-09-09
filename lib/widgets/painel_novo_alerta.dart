// Formulario de tres etapas usado para criar um alerta.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../services/servico_localizacao.dart';
import '../theme/tema_aplicativo.dart';

class NewAlertResult {
  const NewAlertResult({
    required this.category,
    required this.risk,
    required this.description,
    required this.location,
  });

  final AlertCategory category;
  final RiskLevel risk;
  final String description;
  final DeviceLocation location;
}

/// Fluxo de novo alerta em 3 etapas: categoria -> local -> detalhes.
class NewAlertSheet extends StatefulWidget {
  const NewAlertSheet({super.key});

  static Future<NewAlertResult?> show(BuildContext context) {
    return showModalBottomSheet<NewAlertResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const NewAlertSheet(),
    );
  }

  @override
  State<NewAlertSheet> createState() => _NewAlertSheetState();
}

class _NewAlertSheetState extends State<NewAlertSheet> {
  static const _titles = [
    'Qual e a ocorrencia?',
    'Onde aconteceu?',
    'Detalhes do alerta',
  ];

  int _step = 0;
  AlertCategory? _category;
  RiskLevel _risk = RiskLevel.medio;
  final _description = TextEditingController();
  DeviceLocation? _location;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    if (mounted) setState(() => _locationError = null);
    try {
      _updateLocation(await DeviceLocationService.locate());
    } catch (error) {
      _updateLocationError(error);
    }
  }

  void _updateLocation(DeviceLocation location) {
    if (!mounted) return;
    setState(() {
      _location = location;
      _locationError = null;
    });
  }

  void _updateLocationError(Object error) {
    if (mounted) setState(() => _locationError = error.toString());
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    Navigator.of(context).pop(
      NewAlertResult(
        category: _category!,
        risk: _risk,
        description: _description.text.trim(),
        location: _location!,
      ),
    );
  }

  bool get _canAdvance {
    if (_step == 0) {
      return _category != null;
    }
    if (_step == 1) {
      return _location != null;
    }
    return true;
  }

  Widget get _stepContent {
    if (_step == 0) {
      return _categoryStep();
    }
    if (_step == 1) {
      return _locationStep();
    }
    return _detailsStep();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _titles[_step],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.muted,
                    tooltip: 'Fechar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              i <= _step ? AppColors.primary : AppColors.glass,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _stepContent,
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _canAdvance ? _next : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.critical,
                  disabledBackgroundColor: AppColors.glass,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _step == 2 ? 'Publicar alerta' : 'Continuar',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryStep() => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in AlertCategory.values)
            GestureDetector(
              onTap: () => setState(() {
                _category = c;
                _risk = c.defaultRisk;
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _category == c
                      ? c.defaultRisk.color.withValues(alpha: 0.2)
                      : AppColors.glass,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _category == c
                        ? c.defaultRisk.color.withValues(alpha: 0.5)
                        : AppColors.glassBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      c.icon,
                      size: 19,
                      color: c.defaultRisk.color,
                    ),
                    const SizedBox(width: 8),
                    Text(c.label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _locationStep() {
    final locationText = _location?.address ??
        _locationError ??
        'Buscando sua localizacao atual...';

    return GestureDetector(
      onTap: _locationError == null ? null : _loadLocation,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.my_location_outlined,
              size: 21,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usar minha localizacao atual',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locationText,
                    style:
                        const TextStyle(fontSize: 11.5, color: AppColors.muted),
                  ),
                  if (_locationError != null)
                    const Text(
                      'Toque para tentar novamente',
                      style: TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                  if (kIsWeb && _location?.attribution != null)
                    Text(
                      _location!.attribution!,
                      style: const TextStyle(
                          fontSize: 9.5, color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _description,
            maxLines: 4,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Descreva o que aconteceu (opcional)',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              filled: true,
              fillColor: AppColors.glass,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final r in RiskLevel.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _risk = r),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _risk == r
                            ? r.color.withValues(alpha: 0.2)
                            : AppColors.glass,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _risk == r
                              ? r.color.withValues(alpha: 0.5)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        r.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _risk == r ? r.color : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
}
