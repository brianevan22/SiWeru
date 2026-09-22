import 'package:flutter/foundation.dart';

/// Base URL API otomatis menyesuaikan platform tempat aplikasi berjalan,
/// jadi SATU kode ini bisa dipakai bergantian di Chrome maupun HP fisik
/// tanpa perlu diubah-ubah lagi tiap ganti device.
///
/// - Chrome / Web / Windows desktop  -> http://127.0.0.1:8000/api
///   (karena browser & backend jalan di laptop yang sama)
/// - HP fisik (Android/iOS)          -> pakai `_lanIp` di bawah
///   (HP harus 1 WiFi dengan laptop, backend jalan dgn --host=0.0.0.0)
/// - Emulator Android                -> http://10.0.2.2:8000/api
class ApiConfig {
  /// IP WiFi laptop Anda (cek dengan perintah `ipconfig` -> IPv4 Address
  /// pada bagian "Wireless LAN adapter Wi-Fi").
  ///
  /// GANTI nilai ini kalau IP laptop berubah (misal setelah reconnect WiFi).
  /// Hanya dipakai saat menjalankan aplikasi di HP FISIK.
  static const String _lanIp = '192.168.0.104';

  /// Set true kalau sedang testing di EMULATOR Android (bukan HP fisik).
  /// Biarkan false kalau pakai HP fisik.
  static const bool _pakaiEmulator = false;

  /// Kalau backend sudah online di hosting, isi ini (contoh:
  /// 'https://werungotok.my.id/api'). Kalau diisi, nilai ini menang
  /// atas semua deteksi otomatis di bawah.
  static const String? _hostingUrl = null;

  static String get baseUrl {
    if (_hostingUrl != null) return _hostingUrl!;

    // Chrome, Edge, Windows desktop -> backend ada di laptop yang sama
    if (kIsWeb) return 'http://127.0.0.1:8000/api';

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      // 10.0.2.2 = alias khusus emulator Android untuk localhost laptop
      if (_pakaiEmulator) return 'http://10.0.2.2:8000/api';
      // HP fisik -> akses lewat IP laptop di jaringan WiFi
      return 'http://$_lanIp:8000/api';
    }

    // Windows / macOS / Linux desktop
    return 'http://127.0.0.1:8000/api';
  }

  /// Base URL tanpa /api, dipakai untuk mengakses file di /storage/...
  static String get storageBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api$'), '');

  /// Ubah path relatif (contoh: "ktp/xxxx.jpg") hasil dari backend
  /// menjadi URL lengkap yang bisa ditampilkan Image.network.
  static String fileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$storageBaseUrl/storage/$path';
  }
}
