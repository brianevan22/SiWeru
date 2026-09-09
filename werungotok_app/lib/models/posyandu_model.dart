class PosyanduJadwalModel {
  final String namaPosyandu;
  final String? kategori;
  final List<int?> bulan; // index 0=Jan ... 11=Des

  PosyanduJadwalModel({
    required this.namaPosyandu,
    this.kategori,
    required this.bulan,
  });

  factory PosyanduJadwalModel.fromJson(Map<String, dynamic> json) {
    const keys = [
      'jan', 'feb', 'mar', 'apr', 'mei', 'jun',
      'jul', 'agu', 'sep', 'okt', 'nop', 'des',
    ];
    return PosyanduJadwalModel(
      namaPosyandu: json['nama_posyandu'] ?? '',
      kategori: json['kategori'],
      bulan: keys.map((k) => json[k] as int?).toList(),
    );
  }
}

class PosyanduInfoModel {
  final String judul;
  final String isi;

  PosyanduInfoModel({required this.judul, required this.isi});

  factory PosyanduInfoModel.fromJson(Map<String, dynamic> json) {
    return PosyanduInfoModel(judul: json['judul'] ?? '', isi: json['isi'] ?? '');
  }
}

class PosyanduDataModel {
  final String judul;
  final List<PosyanduJadwalModel> jadwal;
  final List<PosyanduInfoModel> keterangan;
  final String? ketuaPkk;
  final String? koordinatorKader;

  PosyanduDataModel({
    required this.judul,
    required this.jadwal,
    required this.keterangan,
    this.ketuaPkk,
    this.koordinatorKader,
  });

  factory PosyanduDataModel.fromJson(Map<String, dynamic> json) {
    return PosyanduDataModel(
      judul: json['judul'] ?? '',
      jadwal: (json['jadwal'] as List? ?? [])
          .map((e) => PosyanduJadwalModel.fromJson(e))
          .toList(),
      keterangan: (json['keterangan'] as List? ?? [])
          .map((e) => PosyanduInfoModel.fromJson(e))
          .toList(),
      ketuaPkk: json['ketua_pkk'],
      koordinatorKader: json['koordinator_kader'],
    );
  }
}
