import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'crop_screen.dart';

/// Pilih foto lalu potong (crop) agar pas sebelum dipakai.
/// Layar crop sekaligus menjadi langkah konfirmasi, sehingga foto tidak
/// langsung terganti kalau tombol tidak sengaja tertekan.
///
/// Mengembalikan path file hasil crop, atau null bila dibatalkan.
Future<String?> pilihDanPotongFoto(
  BuildContext context, {
  required ImageSource sumber,
  String judul = 'Sesuaikan Foto',
  String namaKeluaran = 'foto',
}) async {
  final picked = await ImagePicker().pickImage(
    source: sumber,
    imageQuality: 90,
  );
  if (picked == null) return null;
  if (!context.mounted) return null;

  return potongFoto(context, picked.path,
      judul: judul, namaKeluaran: namaKeluaran);
}

/// Potong file gambar yang sudah ada (mis. hasil FilePicker).
/// Mengembalikan path hasil crop, atau null bila dibatalkan.
Future<String?> potongFoto(
  BuildContext context,
  String path, {
  String judul = 'Sesuaikan Foto',
  String namaKeluaran = 'foto',
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => CropScreen(
        sourcePath: path,
        judul: judul,
        namaKeluaran: namaKeluaran,
      ),
      fullscreenDialog: true,
    ),
  );
}

/// Cek apakah path file berupa gambar (untuk menentukan perlu di-crop atau tidak).
bool adalahGambar(String path) {
  final p = path.toLowerCase();
  return p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png');
}
