import 'package:flutter/material.dart';

import '../services/servico_autenticacao.dart';
import '../theme/tema_aplicativo.dart';
import 'logo_aplicativo.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key, this.reason});

  final String? reason;

  static Future<bool?> show(BuildContext context, {String? reason}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AuthSheet(reason: reason),
    );
  }

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _registerMode = false;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_registerMode) {
        await _auth.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
        if (!mounted) return;
        setState(() {
          _registerMode = false;
          _password.clear();
        });
        _message('Cadastro concluído. Agora faça seu login.');
      } else {
        await _auth.login(email: _email.text, password: _password.text);
        if (mounted) Navigator.pop(context, true);
      }
    } on AuthException catch (error) {
      if (mounted) _message(error.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.critical : AppColors.safe,
      ),
    );
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _registerMode = !_registerMode;
      _password.clear();
    });
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
                    const Center(child: AppLogo()),
                    const SizedBox(height: 14),
                    Text(
                      _registerMode
                          ? 'Crie seu cadastro'
                          : 'Entre na sua conta para colaborar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.reason != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.reason!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_registerMode) ...[
                      TextFormField(
                        key: const ValueKey('register-name-field'),
                        controller: _name,
                        enabled: !_loading,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration('Nome', Icons.person_outline),
                        validator: (value) => (value?.trim().length ?? 0) < 2
                            ? 'Informe seu nome.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      key: const ValueKey('auth-email-field'),
                      controller: _email,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration('E-mail', Icons.email_outlined),
                      validator: (value) => RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value?.trim() ?? '')
                          ? null
                          : 'Informe um e-mail válido.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('auth-password-field'),
                      controller: _password,
                      enabled: !_loading,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration:
                          _decoration('Senha', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Use pelo menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      key: const ValueKey('auth-submit-button'),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registerMode ? 'Cadastrar' : 'Entrar'),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _toggleMode,
                      child: Text(
                        _registerMode
                            ? 'Já possui cadastro? Entre aqui'
                            : 'Ainda não possui cadastro? Cadastre-se',
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _loading ? null : () => Navigator.pop(context, false),
                      child: const Text(
                        'Continuar no mapa como visitante',
                        style: TextStyle(color: AppColors.muted),
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

  InputDecoration _decoration(String label, IconData icon) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.glass,
      border: border,
      enabledBorder: border,
    );
  }
}
