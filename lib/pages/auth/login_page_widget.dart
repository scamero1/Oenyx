import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/oenyx_api.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'LoginPage';
  static String routePath = '/login';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = '';
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });
    try {
      final out = await OenyxApi.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      final sessionId = String(out['sessionId'] ?? '');
      final destination = String(out['destination'] ?? '');
      if (!mounted) return;
      context.go('/otp', extra: {'sessionId': sessionId, 'destination': destination});
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.secondaryBackground,
                  border: Border.all(color: theme.alternate.withOpacity(0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OENYX', style: theme.headlineLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Accede con tu correo para ver tus QR.',
                      style: theme.bodyMedium.override(color: theme.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.secondaryBackground,
                  border: Border.all(color: theme.alternate.withOpacity(0.7)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: theme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Correo',
                          labelStyle: theme.labelMedium.override(color: theme.secondaryText),
                          filled: true,
                          fillColor: theme.primaryBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Ingresa tu correo';
                          if (!s.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        style: theme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: theme.labelMedium.override(color: theme.secondaryText),
                          filled: true,
                          fillColor: theme.primaryBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return 'Ingresa tu contraseña';
                          return null;
                        },
                      ),
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(_error, style: theme.bodyMedium.override(color: theme.error)),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Seguridad: el QR solo se muestra dentro de la app OENYX.',
                textAlign: TextAlign.center,
                style: theme.bodySmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

