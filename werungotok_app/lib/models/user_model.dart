class UserModel {
  final int id;
  final String username; // kolom `name` di backend
  final String? nama;
  final String? email;
  final String? wa;
  final String? alamat;
  final String? ktpPhoto;
  final String? pasFoto;
  final String ktpStatus; // unverified | valid | invalid
  final String role; // warga | admin

  UserModel({
    required this.id,
    required this.username,
    this.nama,
    this.email,
    this.wa,
    this.alamat,
    this.ktpPhoto,
    this.pasFoto,
    required this.ktpStatus,
    required this.role,
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
      pasFoto: json['pas_foto'],
      ktpStatus: json['ktp_status'] ?? 'unverified',
      role: json['role'] ?? 'warga',
    );
  }
}
