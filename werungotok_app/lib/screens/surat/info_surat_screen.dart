import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/info_surat_model.dart';
import '../../services/content_service.dart';
import '../../widgets/main_scaffold.dart';
import 'surat_form_screen.dart';

class InfoSuratScreen extends StatefulWidget {
  const InfoSuratScreen({super.key});

  @override
  State<InfoSuratScreen> createState() => _InfoSuratScreenState();
}

class _InfoSuratScreenState extends State<InfoSuratScreen> {
  late Future<_InfoSuratData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_InfoSuratData> _load() async {
    final client = context.read<ApiClient>();
    final service = ContentService(client);
    final alur = await service.alurPelayanan();
    final syarat = await service.syaratSurat();
    return _InfoSuratData(alur: alur, syarat: syarat);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Informasi Surat',
      showBackButton: true,
      body: FutureBuilder<_InfoSuratData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_tree, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text('Alur Pelayanan Digital',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/alur_pelayanan.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Divider(height: 24),
                      ...List.generate(data.alur.length, (i) {
                        final langkah = data.alur[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryBlue,
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 13.5),
                                    children: [
                                      TextSpan(
                                        text: '${langkah.judulLangkah}: ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: langkah.deskripsi),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.checklist, color: AppColors.primaryGreen),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text('Persyaratan Dokumen',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SuratFormScreen()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            child: const Text('Buat Surat',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/syarat_surat.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Divider(height: 24),
                      ...data.syarat.map((s) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.namaSurat,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 6),
                                ...s.daftarSyarat.map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('•  '),
                                          Expanded(
                                              child: Text(item,
                                                  style: const TextStyle(
                                                      fontSize: 13))),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Untuk surat lainnya seperti Ket. Domisili, Rekom BBM, '
                          'Ahli Waris, dan Pindah Masuk, wajib membawa Pengantar '
                          'RT/RW dan identitas diri.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoSuratData {
  final List<AlurLangkahModel> alur;
  final List<SyaratSuratModel> syarat;
  _InfoSuratData({required this.alur, required this.syarat});
}
