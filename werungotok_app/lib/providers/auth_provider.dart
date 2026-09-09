import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, loggedIn, loggedOut }

class AuthProvider extends ChangeNotifier {
  final ApiClient client;
  late final AuthService _authService;

  AuthProvider(this.client) {
    _authService = AuthService(client);
  }

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? token;

  bool get isLoggedIn => status == AuthStatus.loggedIn && currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;

  /// Dipanggil sekali saat aplikasi start (di SplashScreen) untuk
  /// mengecek apakah ada sesi login tersimpan.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken == null) {
      status = AuthStatus.loggedOut;
      notifyListeners();
      return;
    }

    client.setToken(savedToken);
    try {
      final user = await _authService.me();
      token = savedToken;
      currentUser = user;
      status = AuthStatus.loggedIn;
    } catch (_) {
      // token kadaluarsa/invalid
      await prefs.remove('token');
      client.setToken(null);
      status = AuthStatus.loggedOut;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final user = await _authService.login(username, password);
    // AuthService.login sudah memanggil client.setToken(...) di dalamnya,
    // jadi token terbaru bisa langsung diambil dari client.
    currentUser = user;
    token = client.token;
    status = AuthStatus.loggedIn;

    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('token', token!);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token = null;
    currentUser = null;
    status = AuthStatus.loggedOut;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    currentUser = user;
    notifyListeners();
  }
}
