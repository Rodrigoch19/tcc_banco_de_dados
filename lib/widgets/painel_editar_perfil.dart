// Formulario usado para editar o perfil.
import 'package:flutter/material.dart';

import '../models/perfil_comunitario.dart';
import '../theme/tema_aplicativo.dart';

class EditProfileResult {
  const EditProfileResult({required this.name, required this.about});

  final String name;
  final String about;
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final CommunityProfile profile;

  static Future<EditProfileResult?> show(
    BuildContext context, {
    required CommunityProfile profile,
  }) {
    return showModalBottomSheet<EditProfileResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => EditProfileSheet(profile: profile),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _about;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName);
    _about = TextEditingController(text: widget.profile.about);
  }

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      EditProfileResult(
        name: _name.text.trim(),
        about: _about.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editar perfil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Mostre como você contribui com a comunidade.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          tooltip: 'Fechar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('profile-name-field'),
                      controller: _name,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        label: 'Nome público',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? 'Informe um nome com pelo menos 2 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const ValueKey('profile-about-field'),
                      controller: _about,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 180,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration(
                        label: 'Sobre mim',
                        hint: 'Conte como você gosta de ajudar sua vizinhança.',
                        icon: Icons.format_quote_outlined,
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 20
                          ? 'Escreva pelo menos 20 caracteres sobre voce.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const ValueKey('save-profile-button'),
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Salvar perfil'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.muted),
      filled: true,
      fillColor: AppColors.glass,
      border: border,
      enabledBorder: border,
    );
  }
}
