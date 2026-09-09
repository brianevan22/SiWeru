import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../widgets/main_scaffold.dart';
import '../surat/info_surat_screen.dart';
import '../surat/surat_form_screen.dart';
import '../posyandu/posyandu_screen.dart';
import '../bank_sampah/bank_sampah_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Beranda',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BubbleCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      children: [
                        TextSpan(text: 'Portal Digital '),
                        TextSpan(
                          text: 'Werungotok',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Layanan mandiri masyarakat yang cepat, transparan, dan inovatif.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              imageAsset: 'assets/images/alur_pelayanan.png',
              title: 'Pelayanan Surat',
              subtitle: 'Informasi alur, syarat, dan pengajuan surat.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InfoSuratScreen()),
              ),
              buttons: [
                _MenuButton(
                  label: 'Lihat Syarat',
                  color: Colors.blue.shade50,
                  textColor: AppColors.primaryBlue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InfoSuratScreen()),
                  ),
                ),
                _MenuButton(
                  label: 'Buat Surat Disini',
                  color: AppColors.primaryBlue,
                  textColor: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SuratFormScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MenuCard(
              imageAsset: 'assets/images/jadwal_posyandu.jpg',
              title: 'Jadwal Posyandu',
              subtitle: 'Informasi kegiatan kesehatan ibu dan balita 2026.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PosyanduScreen()),
              ),
              buttons: [
                _MenuButton(
                  label: 'Lihat Selengkapnya',
                  color: Colors.pink.shade50,
                  textColor: AppColors.pink,
                  fullWidth: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PosyanduScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MenuCard(
              imageAsset: 'assets/images/jadwal_bank_sampah.jpg',
              title: 'Bank Sampah',
              subtitle: 'Tukarkan sampah anorganik menjadi tabungan berkah.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BankSampahScreen()),
              ),
              buttons: [
                _MenuButton(
                  label: 'Lihat Selengkapnya',
                  color: Colors.yellow.shade50,
                  textColor: AppColors.yellow,
                  fullWidth: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BankSampahScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Widget> buttons;

  const _MenuCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return BubbleCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imageAsset,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: buttons.map((b) => Expanded(child: b)).toList()),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool fullWidth;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
