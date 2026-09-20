import 'dart:typed_data';
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
    required Uint8List ktpBytes,
    required String ktpFilename,
    required Uint8List fotoProfilBytes,
    required String fotoProfilFilename,
  }) async {
    await client.postMultipartBytes(
      '/register',
      fields: {
        'username': username,
        'password': password,
        'nama': nama,
        'wa': wa,
        'email': email,
        'alamat': alamat,
      },
      files: [
        UploadFileBytes(
          field: 'ktp_photo',
          bytes: ktpBytes,
          filename: ktpFilename,
        ),
        UploadFileBytes(
          field: 'foto_profil',
          bytes: fotoProfilBytes,
          filename: fotoProfilFilename,
        ),
      ],
    );
  }

  Future<void> logout() async {
    try {
      await client.post('/logout');
    } catch (_) {
      // Abaikan error logout (misal token sudah kadaluarsa)
    } finally {
      client.setToken(null);
    }
  }

  Future<UserModel> me() async {
    final res = await client.get('/me');
    return UserModel.fromJson(res['user']);
  }
}
