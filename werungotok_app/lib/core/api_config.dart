import 'package:flutter/foundation.dart';

/// Base URL API dideteksi otomatis sesuai platform tempat aplikasi berjalan:
///
/// - Chrome / Web (flutter run -d chrome)  -> http://127.0.0.1:8000/api
/// - Emulator Android                       -> http://10.0.2.2:8000/api
///   (10.0.2.2 adalah alias khusus emulator Android untuk mengakses
///   localhost laptop tempat `php artisan serve` berjalan)
/// - iOS Simulator / Desktop                -> http://127.0.0.1:8000/api
///
/// CATATAN untuk HP FISIK (bukan emulator) atau sudah deploy ke hosting:
/// nilai di atas TIDAK akan jalan. Ganti manual variabel `_manualOverride`
/// di bawah ini, contoh:
///   static const String? _manualOverride = 'http://192.168.1.5:8000/api';
/// atau kalau sudah online:
///   static const String? _manualOverride = 'https://domain-anda.com/api';
class ApiConfig {
  /// Isi ini kalau baseUrl otomatis di atas tidak sesuai kebutuhan Anda
  /// (misal testing di HP fisik lewat WiFi, atau backend sudah online).
  /// Biarkan `null` untuk memakai deteksi otomatis.
  static const String? _manualOverride = 'http://192.168.0.105:8000/api';

  static String get baseUrl {
    if (_manualOverride != null) return _manualOverride!;

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// Base URL tanpa /api, dipakai untuk mengakses file di /storage/...
  static String get storageBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api$'), '');

  /// Ubah path relatif (contoh: "ktp/xxxx.jpg") hasil dari backend
  /// menjadi URL lengkap yang bisa ditampilkan Image.network / CachedNetworkImage.
  static String fileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$storageBaseUrl/storage/$path';
  }
}
