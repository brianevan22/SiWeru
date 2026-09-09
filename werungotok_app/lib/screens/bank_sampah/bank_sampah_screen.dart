import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/bank_sampah_model.dart';
import '../../services/content_service.dart';
import '../../widgets/main_scaffold.dart';

class BankSampahScreen extends StatefulWidget {
  const BankSampahScreen({super.key});

  @override
  State<BankSampahScreen> createState() => _BankSampahScreenState();
}

class _BankSampahScreenState extends State<BankSampahScreen> {
  late Future<BankSampahDataModel> _future;

  static const _iconMap = {
    'bottle-water': Icons.water_drop,
    'box': Icons.inventory_2,
    'can-food': Icons.data_saver_off,
    'glass-water': Icons.local_drink,
    'plug': Icons.cable,
    'oil-can': Icons.oil_barrel,
  };

  @override
  void initState() {
    super.initState();
    _future = ContentService(context.read<ApiClient>()).bankSampah();
  }

  IconData _iconFor(String? icon) => _iconMap[icon] ?? Icons.recycling;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Bank Sampah',
      showBackButton: true,
      body: FutureBuilder<BankSampahDataModel>(
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
                          const Icon(Icons.recycling, color: AppColors.yellow),
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
                          'assets/images/jadwal_bank_sampah.jpg',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(data.deskripsi,
                          style: const TextStyle(fontSize: 13.5, height: 1.5)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                size: 18, color: AppColors.yellow),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jadwal Penukaran: ${data.jadwalPenukaran}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jenis Sampah Diterima',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: data.jenisSampah.map((j) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.yellow.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_iconFor(j.icon),
                                    color: AppColors.yellow, size: 26),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                j.nama,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ketentuan Penukaran',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...data.ketentuan.map((k) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 16, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(k,
                                        style: const TextStyle(fontSize: 12.5))),
                              ],
                            ),
                          )),
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
