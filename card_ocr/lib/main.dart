import 'package:card_ocr/core/injection.dart';
import 'package:card_ocr/presentation/screens/history_screen.dart';
import 'package:card_ocr/presentation/screens/scan_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const CardOcrApp());
}

class CardOcrApp extends StatelessWidget {
  const CardOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent), useMaterial3: true),
      home: const ScanScreen(),
      routes: {'/history': (_) => const HistoryScreen()},
    );
  }
}
