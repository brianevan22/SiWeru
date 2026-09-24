import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'app_theme.dart';

/// Layar potong foto sederhana.
///
/// Dibuat sendiri (tidak memakai uCrop) agar:
/// - sisi ATAS/BAWAH/KIRI/KANAN dan keempat pojok sama-sama bisa ditarik,
/// - gambar TIDAK ikut membesar/zoom saat bingkai digeser,
/// - ada tombol "Reset" untuk mengembalikan bingkai ke foto utuh.
class CropScreen extends StatefulWidget {
  final String sourcePath;
  final String judul;

  /// Nama dasar untuk file hasil (mis. "Pengantar RT") agar berkas
  /// tidak bernama "crop_...." dan mudah dikenali admin.
  final String namaKeluaran;

  const CropScreen({
    super.key,
    required this.sourcePath,
    this.judul = 'Sesuaikan Foto',
    this.namaKeluaran = 'foto',
  });

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  /// Bingkai potong dalam koordinat tampilan (relatif terhadap area gambar).
  Rect? _crop;

  /// Area tempat gambar benar-benar tergambar di layar.
  Rect _areaGambar = Rect.zero;

  bool _menyimpan = false;

  /// Ukuran asli gambar, dibaca SEKALI saja saat layar dibuka.
  /// (Dulu dibaca tiap build sehingga terasa berat/lag.)
  int? _lebarAsli;
  int? _tinggiAsli;

  @override
  void initState() {
    super.initState();
    _muatUkuran();
  }

  Future<void> _muatUkuran() async {
    final bytes = await File(widget.sourcePath).readAsBytes();
    // decodeImage hanya dipanggil sekali di sini, bukan di dalam build.
    final gambar = await decodeImageFromList(bytes);
    if (!mounted) return;
    setState(() {
      _lebarAsli = gambar.width;
      _tinggiAsli = gambar.height;
    });
  }

  static const double _minUkuran = 60; // batas terkecil bingkai
  static const double _sentuh = 28; // luas area sentuh handle

  void _resetPenuh() {
    setState(() {
      _crop = Rect.fromLTWH(0, 0, _areaGambar.width, _areaGambar.height);
    });
  }

  /// Hitung area gambar (fit contain) di dalam ruang yang tersedia.
  Rect _hitungAreaGambar(Size ruang, double rasioGambar) {
    final rasioRuang = ruang.width / ruang.height;
    double w, h;
    if (rasioGambar > rasioRuang) {
      w = ruang.width;
      h = w / rasioGambar;
    } else {
      h = ruang.height;
      w = h * rasioGambar;
    }
    final dx = (ruang.width - w) / 2;
    final dy = (ruang.height - h) / 2;
    return Rect.fromLTWH(dx, dy, w, h);
  }

  /// Geser seluruh bingkai.
  void _geser(Offset delta) {
    final c = _crop!;
    var l = c.left + delta.dx;
    var t = c.top + delta.dy;
    l = l.clamp(0.0, _areaGambar.width - c.width);
    t = t.clamp(0.0, _areaGambar.height - c.height);
    setState(() => _crop = Rect.fromLTWH(l, t, c.width, c.height));
  }

  /// Tarik sisi/pojok tertentu.
  void _tarik(Offset delta,
      {bool kiri = false,
      bool kanan = false,
      bool atas = false,
      bool bawah = false}) {
    final c = _crop!;
    var l = c.left, t = c.top, r = c.right, b = c.bottom;

    if (kiri) l = (l + delta.dx).clamp(0.0, r - _minUkuran);
    if (kanan) r = (r + delta.dx).clamp(l + _minUkuran, _areaGambar.width);
    if (atas) t = (t + delta.dy).clamp(0.0, b - _minUkuran);
    if (bawah) b = (b + delta.dy).clamp(t + _minUkuran, _areaGambar.height);

    setState(() => _crop = Rect.fromLTRB(l, t, r, b));
  }

  /// Potong gambar sesuai bingkai lalu kembalikan path hasilnya.
  Future<void> _simpan() async {
    if (_crop == null || _lebarAsli == null) return;
    setState(() => _menyimpan = true);
    try {
      // Ubah koordinat tampilan -> koordinat piksel gambar asli.
      final skala = _lebarAsli! / _areaGambar.width;
      final c = _crop!;
      final x = (c.left * skala).round().clamp(0, _lebarAsli! - 1);
      final y = (c.top * skala).round().clamp(0, _tinggiAsli! - 1);
      final w = (c.width * skala).round().clamp(1, _lebarAsli! - x);
      final h = (c.height * skala).round().clamp(1, _tinggiAsli! - y);

      // Bila bingkai hampir sama dengan foto utuh, pakai file asli saja
      // supaya cepat (tidak perlu decode & encode ulang).
      final hampirPenuh =
          x <= 2 && y <= 2 && w >= _lebarAsli! - 4 && h >= _tinggiAsli! - 4;
      if (hampirPenuh) {
        if (mounted) Navigator.of(context).pop(widget.sourcePath);
        return;
      }

      final bytes = await File(widget.sourcePath).readAsBytes();

      // Proses potong dijalankan di luar UI agar aplikasi tidak macet.
      final hasilBytes = await compute(
        _potongDiLatar,
        _ParamPotong(bytes: bytes, x: x, y: y, w: w, h: h),
      );

      if (hasilBytes == null) {
        if (mounted) Navigator.of(context).pop(widget.sourcePath);
        return;
      }

      final dir = File(widget.sourcePath).parent.path;
      final namaDasar = widget.namaKeluaran
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final nama =
          '${namaDasar.isEmpty ? 'foto' : namaDasar}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tujuan = File('$dir/$nama');
      await tujuan.writeAsBytes(hasilBytes);

      if (mounted) Navigator.of(context).pop(tujuan.path);
    } catch (_) {
      // Bila gagal memotong, pakai foto aslinya saja.
      if (mounted) Navigator.of(context).pop(widget.sourcePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.sourcePath);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(widget.judul,
            style: const TextStyle(color: Colors.white, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _crop == null ? null : _resetPenuh,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            label: const Text('Reset',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          IconButton(
            icon: _menyimpan
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.4),
                  )
                : const Icon(Icons.check),
            onPressed: _menyimpan ? null : _simpan,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  if (_lebarAsli == null || _tinggiAsli == null) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  final rasio = _lebarAsli! / _tinggiAsli!;

                  return LayoutBuilder(
                    builder: (context, cons) {
                      final area = _hitungAreaGambar(
                          Size(cons.maxWidth, cons.maxHeight), rasio);
                      // Simpan area & inisialisasi bingkai penuh sekali saja.
                      if (_areaGambar != area) {
                        _areaGambar = area;
                        _crop ??= Rect.fromLTWH(0, 0, area.width, area.height);
                      }
                      final c = _crop!;

                      return Stack(
                        children: [
                          // Gambar (ukurannya tetap, tidak ikut zoom)
                          Positioned(
                            left: area.left,
                            top: area.top,
                            width: area.width,
                            height: area.height,
                            child: Image.file(
                              file,
                              fit: BoxFit.fill,
                              // Dekode seukuran layar saja supaya ringan;
                              // hasil potongan tetap dari foto asli.
                              cacheWidth: 1080,
                              filterQuality: FilterQuality.low,
                              gaplessPlayback: true,
                            ),
                          ),
                          // Selubung gelap di luar bingkai
                          Positioned(
                            left: area.left,
                            top: area.top,
                            width: area.width,
                            height: area.height,
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _SelubungPainter(c),
                              ),
                            ),
                          ),
                          // Area bingkai: geser seluruhnya
                          Positioned(
                            left: area.left + c.left,
                            top: area.top + c.top,
                            width: c.width,
                            height: c.height,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (d) => _geser(d.delta),
                            ),
                          ),
                          // ===== Handle SISI =====
                          _handle(area, c,
                              left: c.left + c.width / 2 - _sentuh / 2,
                              top: c.top - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) => _tarik(d, atas: true),
                              ikon: Icons.drag_handle),
                          _handle(area, c,
                              left: c.left + c.width / 2 - _sentuh / 2,
                              top: c.bottom - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) => _tarik(d, bawah: true),
                              ikon: Icons.drag_handle),
                          _handle(area, c,
                              left: c.left - _sentuh / 2,
                              top: c.top + c.height / 2 - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) => _tarik(d, kiri: true),
                              ikon: Icons.drag_indicator),
                          _handle(area, c,
                              left: c.right - _sentuh / 2,
                              top: c.top + c.height / 2 - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) => _tarik(d, kanan: true),
                              ikon: Icons.drag_indicator),
                          // ===== Handle POJOK =====
                          _handle(area, c,
                              left: c.left - _sentuh / 2,
                              top: c.top - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) => _tarik(d, kiri: true, atas: true)),
                          _handle(area, c,
                              left: c.right - _sentuh / 2,
                              top: c.top - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) =>
                                  _tarik(d, kanan: true, atas: true)),
                          _handle(area, c,
                              left: c.left - _sentuh / 2,
                              top: c.bottom - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) =>
                                  _tarik(d, kiri: true, bawah: true)),
                          _handle(area, c,
                              left: c.right - _sentuh / 2,
                              top: c.bottom - _sentuh / 2,
                              w: _sentuh,
                              h: _sentuh,
                              onDrag: (d) =>
                                  _tarik(d, kanan: true, bawah: true)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            color: Colors.black,
            child: const Text(
              'Tarik sisi atau pojok bingkai untuk memotong. '
              'Tekan Reset untuk kembali ke foto utuh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle(
    Rect area,
    Rect c, {
    required double left,
    required double top,
    required double w,
    required double h,
    required void Function(Offset) onDrag,
    IconData? ikon,
  }) {
    return Positioned(
      left: area.left + left,
      top: area.top + top,
      width: w,
      height: h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => onDrag(d.delta),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4),
              ],
            ),
            child: ikon != null
                ? Icon(ikon, size: 10, color: AppColors.primaryGreen)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Menggelapkan bagian gambar di luar bingkai + menggambar garis bantu.
class _SelubungPainter extends CustomPainter {
  final Rect crop;
  _SelubungPainter(this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    final gelap = Paint()..color = Colors.black.withOpacity(0.55);

    // Area di luar bingkai digelapkan.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(crop),
      ),
      gelap,
    );

    // Garis bingkai
    final garis = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(crop, garis);

    // Garis bantu sepertiga
    final bantu = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = crop.left + crop.width * i / 3;
      final dy = crop.top + crop.height * i / 3;
      canvas.drawLine(Offset(dx, crop.top), Offset(dx, crop.bottom), bantu);
      canvas.drawLine(Offset(crop.left, dy), Offset(crop.right, dy), bantu);
    }
  }

  @override
  bool shouldRepaint(covariant _SelubungPainter old) => old.crop != crop;
}

/// Parameter untuk proses potong di isolate terpisah.
class _ParamPotong {
  final Uint8List bytes;
  final int x, y, w, h;
  const _ParamPotong({
    required this.bytes,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

/// Dijalankan di luar UI (isolate) supaya aplikasi tetap lancar.
Uint8List? _potongDiLatar(_ParamPotong p) {
  final asli = img.decodeImage(p.bytes);
  if (asli == null) return null;
  final hasil = img.copyCrop(asli, x: p.x, y: p.y, width: p.w, height: p.h);
  return Uint8List.fromList(img.encodeJpg(hasil, quality: 88));
}
