import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _tokenKey = 'oenyx_public_token';
  static const _userEmailKey = 'oenyx_public_email';
  static const _userNameKey = 'oenyx_public_name';

  static SharedPreferences? _prefs;
  static String _token = '';
  static String _email = '';
  static String _name = '';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(_tokenKey) ?? '';
    _email = _prefs?.getString(_userEmailKey) ?? '';
    _name = _prefs?.getString(_userNameKey) ?? '';
  }

  static String get token => _token;
  static String get email => _email;
  static String get name => _name;
  static bool get isLoggedIn => _token.isNotEmpty;

  static Future<void> setSession({
    required String token,
    required String email,
    required String name,
  }) async {
    _token = token;
    _email = email;
    _name = name;
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_userEmailKey, email);
    await _prefs?.setString(_userNameKey, name);
  }

  static Future<void> clear() async {
    _token = '';
    _email = '';
    _name = '';
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userEmailKey);
    await _prefs?.remove(_userNameKey);
  }
}

