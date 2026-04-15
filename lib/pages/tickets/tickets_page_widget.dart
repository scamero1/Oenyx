import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/oenyx_api.dart';
import '../../services/session_store.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class TicketsPageWidget extends StatefulWidget {
  const TicketsPageWidget({super.key});

  static String routeName = 'TicketsPage';
  static String routePath = '/tickets';

  @override
  State<TicketsPageWidget> createState() => _TicketsPageWidgetState();
}

class _TicketsPageWidgetState extends State<TicketsPageWidget> {
  bool _loading = true;
  String _error = '';
  List<dynamic> _tickets = const [];
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await OenyxApi.getMyTickets();
      if (!mounted) return;
      setState(() {
        _tickets = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
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
        title: Text('Mis QR', style: theme.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionStore.clear();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.secondaryBackground,
                  border: Border.all(color: theme.alternate.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: theme.accent1,
                        border: Border.all(color: theme.primary.withOpacity(0.25)),
                      ),
                      child: Icon(Icons.verified_user, color: theme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(SessionStore.name.isEmpty ? 'Cuenta' : SessionStore.name, style: theme.titleSmall),
                          Text(SessionStore.email, style: theme.bodySmall.override(color: theme.secondaryText)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: theme.accent2,
                        border: Border.all(color: theme.secondary.withOpacity(0.25)),
                      ),
                      child: Text(
                        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                        style: theme.bodyMedium.override(
                          fontFamily: 'Roboto Mono',
                          fontWeight: FontWeight.w700,
                          color: theme.primaryBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: theme.primary))
                    : _error.isNotEmpty
                        ? Center(child: Text(_error, style: theme.bodyMedium.override(color: theme.error)))
                        : _tickets.isEmpty
                            ? Center(
                                child: Text(
                                  'No tienes tickets activos.',
                                  style: theme.bodyMedium.override(color: theme.secondaryText),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _tickets.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final t = _tickets[i] is Map ? _tickets[i] as Map : {};
                                  final id = t['id'] is int ? t['id'] as int : int.tryParse('${t['id'] ?? ''}') ?? 0;
                                  final evento = '${t['evento'] ?? ''}';
                                  final zona = '${t['zona'] ?? ''}';
                                  final lugar = '${t['lugar'] ?? ''}';
                                  final asiento = '${t['asiento_codigo'] ?? ''}';
                                  final isActive = t['is_active'] == true;

                                  return InkWell(
                                    onTap: () => context.go('/tickets/$id', extra: t),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: theme.secondaryBackground,
                                        border: Border.all(color: theme.alternate.withOpacity(0.7)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: isActive ? theme.accent2 : theme.accent1,
                                              border: Border.all(
                                                color: (isActive ? theme.secondary : theme.primary).withOpacity(0.25),
                                              ),
                                            ),
                                            child: Icon(
                                              isActive ? Icons.qr_code_2 : Icons.lock,
                                              color: isActive ? theme.secondaryBackground : theme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(evento, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleSmall),
                                                const SizedBox(height: 4),
                                                Text(
                                                  lugar,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.bodySmall.override(color: theme.secondaryText),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '$zona${asiento.isNotEmpty ? ' · $asiento' : ''}',
                                                  style: theme.bodySmall.override(color: theme.secondaryText),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(Icons.chevron_right, color: theme.secondaryText),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

