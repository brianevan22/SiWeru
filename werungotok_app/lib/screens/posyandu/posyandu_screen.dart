import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/posyandu_model.dart';
import '../../services/content_service.dart';
import '../../widgets/main_scaffold.dart';

class PosyanduScreen extends StatefulWidget {
  const PosyanduScreen({super.key});

  @override
  State<PosyanduScreen> createState() => _PosyanduScreenState();
}

class _PosyanduScreenState extends State<PosyanduScreen> {
  late Future<PosyanduDataModel> _future;

  static const _bulanLabel = [
    'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
    'JUL', 'AGU', 'SEP', 'OKT', 'NOP', 'DES',
  ];

  @override
  void initState() {
    super.initState();
    _future = ContentService(context.read<ApiClient>()).posyandu();
  }

  Color _rowColor(String? kategori) {
    switch (kategori) {
      case 'lansia':
        return Colors.orange.shade200;
      case 'kader':
        return Colors.yellow.shade200;
      case 'imunisasi':
        return Colors.green.shade100;
      default:
        return Colors.orange.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Posyandu',
      showBackButton: true,
      body: FutureBuilder<PosyanduDataModel>(
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
                      Row(
                        children: [
                          const Icon(Icons.child_care, color: AppColors.pink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(data.judul,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/jadwal_posyandu.jpg',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Keterangan & Informasi Layanan Posyandu:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 10),
                      ...data.keterangan.map((k) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 12.5),
                                children: [
                                  TextSpan(
                                      text: '${k.judul}: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: k.isi),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BubbleCard(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.pink.shade50),
                      columns: [
                        const DataColumn(
                            label: Text('POSYANDU',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        ..._bulanLabel.map((b) => DataColumn(
                            label: Text(b,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11)))),
                      ],
                      rows: data.jadwal.map((j) {
                        return DataRow(
                          color: WidgetStateProperty.all(_rowColor(j.kategori)),
                          cells: [
                            DataCell(Text(j.namaPosyandu,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600))),
                            ...j.bulan.map((tgl) => DataCell(
                                Text(tgl?.toString() ?? '-',
                                    style: const TextStyle(fontSize: 11)))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (data.ketuaPkk != null || data.koordinatorKader != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Ketua TP PKK: ${data.ketuaPkk ?? '-'} | '
                      'Koordinator Kader: ${data.koordinatorKader ?? '-'}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
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
