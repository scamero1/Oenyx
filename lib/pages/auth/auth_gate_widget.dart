import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/session_store.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class AuthGateWidget extends StatefulWidget {
  const AuthGateWidget({super.key});

  static String routeName = 'AuthGate';
  static String routePath = '/';

  @override
  State<AuthGateWidget> createState() => _AuthGateWidgetState();
}

class _AuthGateWidgetState extends State<AuthGateWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SessionStore.isLoggedIn) {
        context.go('/tickets');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.secondary.withOpacity(0.25), width: 3),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
              const SizedBox(height: 16),
              Text('Cargando OENYX…', style: theme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

