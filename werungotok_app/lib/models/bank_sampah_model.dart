class JenisSampahModel {
  final String nama;
  final String? icon;

  JenisSampahModel({required this.nama, this.icon});

  factory JenisSampahModel.fromJson(Map<String, dynamic> json) {
    return JenisSampahModel(nama: json['nama'] ?? '', icon: json['icon']);
  }
}

class BankSampahDataModel {
  final String judul;
  final String deskripsi;
  final String jadwalPenukaran;
  final List<String> ketentuan;
  final List<JenisSampahModel> jenisSampah;

  BankSampahDataModel({
    required this.judul,
    required this.deskripsi,
    required this.jadwalPenukaran,
    required this.ketentuan,
    required this.jenisSampah,
  });

  factory BankSampahDataModel.fromJson(Map<String, dynamic> json) {
    return BankSampahDataModel(
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jadwalPenukaran: json['jadwal_penukaran'] ?? '',
      ketentuan: (json['ketentuan'] as List? ?? [])
          .map((e) => (e['isi'] ?? '').toString())
          .toList(),
      jenisSampah: (json['jenis_sampah'] as List? ?? [])
          .map((e) => JenisSampahModel.fromJson(e))
          .toList(),
    );
  }
}
