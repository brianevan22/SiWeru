class InfoSuratSettingModel {
  final String? keterangan;
  final String? gambarAlur;
  final String? gambarSyarat;
  final String? gambarPosyandu;

  InfoSuratSettingModel({
    this.keterangan,
    this.gambarAlur,
    this.gambarSyarat,
    this.gambarPosyandu,
  });

  factory InfoSuratSettingModel.fromJson(Map<String, dynamic> json) {
    return InfoSuratSettingModel(
      keterangan: json['keterangan'],
      gambarAlur: json['gambar_alur'],
      gambarSyarat: json['gambar_syarat'],
      gambarPosyandu: json['gambar_posyandu'],
    );
  }
}
