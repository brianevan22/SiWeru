import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Exception khusus supaya UI bisa menampilkan pesan error dari Laravel
/// (message / errors validasi) dengan rapi.
class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiException(this.message, {this.errors, this.statusCode});

  /// Ambil pesan error pertama dari struktur validasi Laravel (422),
  /// atau fallback ke `message` biasa.
  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final firstKey = errors!.keys.first;
      final val = errors![firstKey];
      if (val is List && val.isNotEmpty) return val.first.toString();
    }
    return message;
  }

  @override
  String toString() => firstError;
}

/// Representasi 1 file untuk diupload lewat bytes (dipakai di Web, di mana
/// `dart:io File` dengan path tidak tersedia). Untuk Android/iOS/Desktop
/// tetap bisa pakai `postMultipart` (berbasis path file) seperti biasa.
class UploadFileBytes {
  final String field;
  final Uint8List bytes;
  final String filename;

  UploadFileBytes({
    required this.field,
    required this.bytes,
    required this.filename,
  });
}

class ApiClient {
  String? _token;

  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$cleanPath').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  dynamic _handle(http.Response res) {
    Map<String, dynamic> body = {};
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        body = {'message': 'Respons server tidak valid.'};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    throw ApiException(
      body['message']?.toString() ?? 'Terjadi kesalahan (${res.statusCode}).',
      errors: body['errors'] as Map<String, dynamic>?,
      statusCode: res.statusCode,
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final res = await http.post(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final res = await http.put(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  /// Kirim request multipart BERBASIS PATH file lokal di device.
  /// Cocok untuk Android/iOS/Desktop. TIDAK bisa dipakai di Web
  /// (pakai [postMultipartBytes] untuk itu).
  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    Map<String, String>? files,
    String method = 'POST',
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(_headers);

    if (fields != null) request.fields.addAll(fields);

    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  /// Kirim request multipart BERBASIS BYTES (aman dipakai di Web maupun
  /// Android/iOS/Desktop). Dipakai untuk upload foto KTP/foto profil saat
  /// registrasi, karena image_picker di Web tidak menghasilkan path file
  /// yang bisa dibaca lewat dart:io File.
  Future<dynamic> postMultipartBytes(
    String path, {
    Map<String, String>? fields,
    List<UploadFileBytes>? files,
    String method = 'POST',
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(_headers);

    if (fields != null) request.fields.addAll(fields);

    if (files != null) {
      for (final f in files) {
        request.files.add(
          http.MultipartFile.fromBytes(f.field, f.bytes, filename: f.filename),
        );
      }
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }
}
