import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../widgets/main_scaffold.dart';
import 'admin_warga_tab.dart';
import 'admin_surat_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialTab;
  const AdminDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Panel Admin',
      showBackButton: true,
      navIndex: NavTab.riwayat,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(26),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textDark,
              dividerColor: Colors.transparent,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              tabs: const [
                Tab(text: 'Verifikasi Warga'),
                Tab(text: 'Kelola Surat'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AdminWargaTab(),
                AdminSuratTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
