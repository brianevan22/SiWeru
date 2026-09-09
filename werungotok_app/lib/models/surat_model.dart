class SuratModel {
  final int id;
  final int userId;
  final String jenisSurat;
  final String dokumenPendukung;
  final String status; // diproses | selesai | ditolak
  final String? fileHasil;
  final String? catatanAdmin;
  final String createdAt;

  // hanya terisi saat admin melihat daftar (relasi user)
  final String? namaPemohon;
  final String? waPemohon;

  SuratModel({
    required this.id,
    required this.userId,
    required this.jenisSurat,
    required this.dokumenPendukung,
    required this.status,
    this.fileHasil,
    this.catatanAdmin,
    required this.createdAt,
    this.namaPemohon,
    this.waPemohon,
  });

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return SuratModel(
      id: json['id'],
      userId: json['user_id'],
      jenisSurat: json['jenis_surat'] ?? '',
      dokumenPendukung: json['dokumen_pendukung'] ?? '',
      status: json['status'] ?? 'diproses',
      fileHasil: json['file_hasil'],
      catatanAdmin: json['catatan_admin'],
      createdAt: json['created_at'] ?? '',
      namaPemohon: user?['nama'] ?? user?['name'],
      waPemohon: user?['wa'],
    );
  }
}
