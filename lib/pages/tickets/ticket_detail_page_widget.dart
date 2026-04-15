import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/oenyx_api.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class TicketDetailPageWidget extends StatefulWidget {
  const TicketDetailPageWidget({super.key, required this.ticketId, this.ticket});

  final int ticketId;
  final Map? ticket;

  static String routeName = 'TicketDetail';

  @override
  State<TicketDetailPageWidget> createState() => _TicketDetailPageWidgetState();
}

class _TicketDetailPageWidgetState extends State<TicketDetailPageWidget> {
  Timer? _clock;
  DateTime _now = DateTime.now();
  bool _loadingVerif = false;
  String _verifError = '';
  List<dynamic> _verifs = const [];

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
    _loadVerifications();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _loadingVerif = true;
      _verifError = '';
    });
    try {
      final out = await OenyxApi.getTicketVerifications(widget.ticketId);
      final items = out['items'] is List ? out['items'] as List : <dynamic>[];
      if (!mounted) return;
      setState(() {
        _verifs = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingVerif = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = widget.ticket ?? {};
    final evento = '${t['evento'] ?? ''}';
    final lugar = '${t['lugar'] ?? ''}';
    final zona = '${t['zona'] ?? ''}';
    final asiento = '${t['asiento_codigo'] ?? ''}';
    final isActive = t['is_active'] == true;
    final qrPayload = isActive ? '${t['qr_code'] ?? ''}' : '';
    final activationTime = '${t['activation_time'] ?? ''}';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        title: Text('Entrada #${widget.ticketId}', style: theme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingVerif ? null : _loadVerifications,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.secondaryBackground,
                border: Border.all(color: theme.alternate.withOpacity(0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento, style: theme.titleLarge),
                  const SizedBox(height: 6),
                  Text(lugar, style: theme.bodyMedium.override(color: theme.secondaryText)),
                  const SizedBox(height: 10),
                  Text(
                    '$zona${asiento.isNotEmpty ? ' · $asiento' : ''}',
                    style: theme.bodyMedium.override(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.secondaryBackground,
                border: Border.all(color: theme.alternate.withOpacity(0.7)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? theme.secondary : theme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isActive ? 'QR activo' : 'QR bloqueado (se habilita 2 horas antes)',
                          style: theme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                        style: theme.bodySmall.override(
                          fontFamily: 'Roboto Mono',
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: isActive && qrPayload.isNotEmpty
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              QrImageView(
                                data: qrPayload,
                                version: QrVersions.auto,
                                size: 260,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: const Color(0xFF0B0B0F).withOpacity(0.85),
                                  ),
                                  child: Text(
                                    '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                                    style: theme.bodySmall.override(
                                      fontFamily: 'Roboto Mono',
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Icon(Icons.lock, size: 52, color: theme.primary),
                              const SizedBox(height: 10),
                              Text('Aún no disponible', style: theme.titleSmall.override(color: theme.primaryText)),
                              const SizedBox(height: 6),
                              Text(
                                activationTime.isEmpty ? 'Vuelve más tarde.' : 'Activación: $activationTime',
                                textAlign: TextAlign.center,
                                style: theme.bodySmall.override(color: theme.secondaryText),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tip: el reloj y el indicador en vivo ayudan a detectar fotos.',
                    style: theme.bodySmall.override(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.secondaryBackground,
                border: Border.all(color: theme.alternate.withOpacity(0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verificaciones', style: theme.titleMedium),
                  const SizedBox(height: 10),
                  if (_loadingVerif) ...[
                    LinearProgressIndicator(color: theme.primary),
                  ] else if (_verifError.isNotEmpty) ...[
                    Text(_verifError, style: theme.bodyMedium.override(color: theme.error)),
                  ] else if (_verifs.isEmpty) ...[
                    Text('Sin verificaciones registradas.', style: theme.bodyMedium.override(color: theme.secondaryText)),
                  ] else ...[
                    ..._verifs.take(20).map((v) {
                      final m = v is Map ? v : {};
                      final when = '${m['created_at'] ?? ''}';
                      final gate = '${m['ubicacion'] ?? ''}';
                      final tipo = '${m['tipo'] ?? ''}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: theme.primaryBackground,
                            border: Border.all(color: theme.alternate.withOpacity(0.7)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: theme.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tipo.isEmpty ? 'Verificado' : tipo, style: theme.titleSmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      gate,
                                      style: theme.bodySmall.override(color: theme.secondaryText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      when,
                                      style: theme.bodySmall.override(color: theme.secondaryText, fontFamily: 'Roboto Mono'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

