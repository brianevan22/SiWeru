import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const WerungotokApp());
}

class WerungotokApp extends StatelessWidget {
  const WerungotokApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Satu ApiClient dipakai bersama oleh AuthProvider & seluruh service,
    // supaya token yang tersimpan otomatis dipakai di semua request.
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'Werungotok',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
