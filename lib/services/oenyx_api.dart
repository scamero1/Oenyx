import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_store.dart';

class OenyxApi {
  static const String baseUrl = 'https://oenyx.com/api';

  static Map<String, String> _headers({bool auth = false, bool app = false}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (app) {
      h['X-OENYX-APP'] = '1';
    }
    if (auth) {
      final t = SessionStore.token;
      if (t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }
    return h;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth-web/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) {
      throw Exception((body is Map && body['error'] != null) ? body['error'] : 'No se pudo iniciar sesión');
    }
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> verifyLoginOtp({
    required String sessionId,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth-web/login/verify'),
      headers: _headers(),
      body: jsonEncode({'sessionId': sessionId, 'code': code}),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) {
      throw Exception((body is Map && body['error'] != null) ? body['error'] : 'Código inválido');
    }
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  static Future<List<dynamic>> getMyTickets() async {
    final res = await http.get(
      Uri.parse('$baseUrl/store/my-tickets'),
      headers: _headers(auth: true, app: true),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : [];
    if (res.statusCode >= 400) {
      throw Exception((body is Map && body['error'] != null) ? body['error'] : 'No se pudieron cargar tus tickets');
    }
    return body is List ? body : [];
  }

  static Future<Map<String, dynamic>> getTicketVerifications(int ticketId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/store/tickets/$ticketId/verifications'),
      headers: _headers(auth: true, app: true),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) {
      throw Exception((body is Map && body['error'] != null) ? body['error'] : 'No se pudieron cargar las verificaciones');
    }
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }
}

