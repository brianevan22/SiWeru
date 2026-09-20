class AlurLangkahModel {
  final int id;
  final String judulLangkah;
  final String deskripsi;

  AlurLangkahModel({
    required this.id,
    required this.judulLangkah,
    required this.deskripsi,
  });

  factory AlurLangkahModel.fromJson(Map<String, dynamic> json) {
    return AlurLangkahModel(
      id: json['id'] ?? 0,
      judulLangkah: json['judul_langkah'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }
}

class SyaratSuratModel {
  final String namaSurat;
  final List<String> daftarSyarat;

  SyaratSuratModel({required this.namaSurat, required this.daftarSyarat});

  factory SyaratSuratModel.fromJson(Map<String, dynamic> json) {
    return SyaratSuratModel(
      namaSurat: json['nama_surat'] ?? '',
      daftarSyarat: (json['daftar_syarat'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
