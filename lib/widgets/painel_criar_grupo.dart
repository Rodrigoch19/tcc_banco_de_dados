// Formulario usado para criar um grupo.
import 'package:flutter/material.dart';

import '../models/grupo_comunitario.dart';
import '../theme/tema_aplicativo.dart';

class CreateGroupResult {
  const CreateGroupResult({
    required this.name,
    required this.description,
    required this.category,
  });

  final String name;
  final String description;
  final GroupCategory category;
}

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  static Future<CreateGroupResult?> show(BuildContext context) {
    return showModalBottomSheet<CreateGroupResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const CreateGroupSheet(),
    );
  }

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  GroupCategory _category = GroupCategory.values.first;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      CreateGroupResult(
        name: _name.text.trim(),
        description: _description.text.trim(),
        category: _category,
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
                                'Criar grupo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'O grupo sera criado na sua localizacao atual.',
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
                      key: const ValueKey('group-name-field'),
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nome do grupo',
                        'Ex.: Vizinhos do Parque',
                        Icons.groups_outlined,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.length < 3) {
                          return 'Informe um nome com pelo menos 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<GroupCategory>(
                      key: const ValueKey('group-category-field'),
                      initialValue: _category,
                      decoration: _decoration(
                        'Categoria',
                        null,
                        Icons.category_outlined,
                      ),
                      items: [
                        for (final category in GroupCategory.values)
                          DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, size: 18),
                                const SizedBox(width: 10),
                                Text(category.label),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('group-description-field'),
                      controller: _description,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration(
                        'Sobre o que e o grupo?',
                        'Conte o objetivo e as regras principais.',
                        Icons.notes_outlined,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.length < 10) {
                          return 'Descreva o grupo em pelo menos 10 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const ValueKey('create-group-submit'),
                      onPressed: _submit,
                      icon: const Icon(Icons.add),
                      label: const Text('Criar e abrir conversa'),
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

  InputDecoration _decoration(
    String label,
    String? hint,
    IconData icon,
  ) {
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
