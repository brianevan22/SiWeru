import 'dart:convert';
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

  /// Kirim request multipart (untuk upload file: foto KTP, dokumen surat, dll).
  /// [files] berupa map: key field => path file lokal di device.
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
}
