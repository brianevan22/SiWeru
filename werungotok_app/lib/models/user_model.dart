import 'surat_model.dart';

class UserModel {
  final int id;
  final String username; // kolom `name` di backend
  final String? nama;
  final String? email;
  final String? wa;
  final String? alamat;
  final String? ktpPhoto;
  final String? fotoProfil; // Diperbarui dari pasFoto
  final String ktpStatus; // unverified | valid | invalid
  final String role; // warga | admin

  // Hanya terisi saat admin melihat daftar warga (relasi surat_pengajuans).
  final List<SuratModel> riwayatSurat;

  UserModel({
    required this.id,
    required this.username,
    this.nama,
    this.email,
    this.wa,
    this.alamat,
    this.ktpPhoto,
    this.fotoProfil, // Diperbarui dari pasFoto
    required this.ktpStatus,
    required this.role,
    this.riwayatSurat = const [],
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['name'] ?? '',
      nama: json['nama'],
      email: json['email'],
      wa: json['wa'],
      alamat: json['alamat'],
      ktpPhoto: json['ktp_photo'],
      fotoProfil: json['foto_profil'] ??
          json[
              'pas_foto'], // Diperbarui dengan fallback ke pas_foto jika backend masih versi lama
      ktpStatus: json['ktp_status'] ?? 'unverified',
      role: json['role'] ?? 'warga',
      riwayatSurat: (json['surat_pengajuans'] as List?)
              ?.map((e) => SuratModel.fromJson(e))
              .toList() ??
          const [],
    );
  }
}
