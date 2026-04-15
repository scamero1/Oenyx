import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/oenyx_api.dart';
import '../../services/session_store.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class OtpPageWidget extends StatefulWidget {
  const OtpPageWidget({super.key, required this.sessionId, required this.destination});

  final String sessionId;
  final String destination;

  static String routeName = 'OtpPage';
  static String routePath = '/otp';

  @override
  State<OtpPageWidget> createState() => _OtpPageWidgetState();
}

class _OtpPageWidgetState extends State<OtpPageWidget> {
  final _code = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final code = _code.text.trim();
    setState(() {
      _error = '';
    });
    if (code.length < 4) {
      setState(() {
        _error = 'Ingresa el código';
      });
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      final out = await OenyxApi.verifyLoginOtp(sessionId: widget.sessionId, code: code);
      final token = String(out['token'] ?? '');
      final user = out['user'] is Map ? out['user'] as Map : {};
      final email = String(user['email'] ?? '');
      final name = String(user['nombre'] ?? '');
      if (token.isEmpty) throw Exception('No se recibió token');
      await SessionStore.setSession(token: token, email: email, name: name);
      if (!mounted) return;
      context.go('/tickets');
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
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        title: Text('Verificación', style: theme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                    Text('Código enviado', style: theme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      widget.destination.isEmpty ? 'Revisa tu correo.' : widget.destination,
                      style: theme.bodyMedium.override(color: theme.secondaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      style: theme.titleLarge,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '000000',
                        filled: true,
                        fillColor: theme.primaryBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
                        onPressed: _loading ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.secondary,
                          foregroundColor: theme.primaryBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Verificar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tus datos están protegidos.',
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

