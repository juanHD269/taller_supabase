// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // flutter pub add provider
import 'pages/home_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final url = dotenv.env['SUPABASE_URL']!;
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const FinanceApp(),
    ),
  );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();
    return MaterialApp(
      title: 'Personal Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ctrl.mode,
      home: const HomePage(),
    );
  }
}
