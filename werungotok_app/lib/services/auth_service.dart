import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient client;
  AuthService(this.client);

  Future<UserModel> login(String username, String password) async {
    final res = await client.post('/login', body: {
      'username': username,
      'password': password,
    });
    client.setToken(res['token']);
    return UserModel.fromJson(res['user']);
  }

  Future<void> register({
    required String username,
    required String password,
    required String nama,
    required String wa,
    required String email,
    required String alamat,
    required String ktpPhotoPath,
    required String pasFotoPath,
  }) async {
    await client.postMultipart(
      '/register',
      fields: {
        'username': username,
        'password': password,
        'nama': nama,
        'wa': wa,
        'email': email,
        'alamat': alamat,
      },
      files: {
        'ktp_photo': ktpPhotoPath,
        'pas_foto': pasFotoPath,
      },
    );
  }

  Future<void> logout() async {
    try {
      await client.post('/logout');
    } catch (_) {
      // abaikan error logout (misal token sudah kadaluarsa)
    } finally {
      client.setToken(null);
    }
  }

  Future<UserModel> me() async {
    final res = await client.get('/me');
    return UserModel.fromJson(res['user']);
  }
}
