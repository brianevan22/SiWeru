class JenisSuratModel {
  final int id;
  final String kode;
  final String namaSurat;
  final String? keterangan;
  final List<String> syaratRequired;
  final bool isActive;

  JenisSuratModel({
    required this.id,
    required this.kode,
    required this.namaSurat,
    this.keterangan,
    required this.syaratRequired,
    this.isActive = true,
  });

  factory JenisSuratModel.fromJson(Map<String, dynamic> json) {
    return JenisSuratModel(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      namaSurat: json['nama_surat'] ?? '',
      keterangan: json['keterangan'],
      syaratRequired: json['syarat_required'] != null
          ? List<String>.from(json['syarat_required'])
          : [],
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true || json['is_active'] == 1),
    );
  }
}

class SuratModel {
  final int id;
  final int userId;
  final String jenisSurat; // kode, mis. SK_MASIH_SEKOLAH
  final String namaSurat; // nama lengkap untuk ditampilkan
  final String keperluan;
  final String dokumenPendukung;
  final String status; // diproses | selesai | ditolak
  final String? fileHasil;
  final String? catatanAdmin;
  final String createdAt;

  // hanya terisi saat admin melihat daftar (relasi user)
  final String? namaPemohon;
  final String? waPemohon;
  final String? alamatPemohon;
  final String? fotoPemohon; // foto profil warga
  final String? ktpPemohon; // path foto KTP warga
  final String? ktpStatusPemohon;

  SuratModel({
    required this.id,
    required this.userId,
    required this.jenisSurat,
    required this.namaSurat,
    required this.keperluan,
    required this.dokumenPendukung,
    required this.status,
    this.fileHasil,
    this.catatanAdmin,
    required this.createdAt,
    this.namaPemohon,
    this.waPemohon,
    this.alamatPemohon,
    this.fotoPemohon,
    this.ktpPemohon,
    this.ktpStatusPemohon,
  });

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return SuratModel(
      id: json['id'],
      userId: json['user_id'],
      jenisSurat: json['jenis_surat'] ?? '',
      namaSurat: json['nama_surat'] ?? json['jenis_surat'] ?? '',
      keperluan: json['keperluan'] ?? '',
      dokumenPendukung: json['dokumen_pendukung'] ?? '',
      status: json['status'] ?? 'diproses',
      fileHasil: json['file_hasil'],
      catatanAdmin: json['catatan_admin'],
      createdAt: json['created_at'] ?? '',
      namaPemohon: user?['nama'] ?? user?['name'],
      waPemohon: user?['wa'],
      alamatPemohon: user?['alamat'],
      fotoPemohon: user?['foto_profil'],
      ktpPemohon: user?['ktp_photo'],
      ktpStatusPemohon: user?['ktp_status'],
    );
  }
}
