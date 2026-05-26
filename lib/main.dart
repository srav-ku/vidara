import 'package:flutter/material.dart';
import 'theme/vidara_theme.dart';
import 'screens/video_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIDARA',
      debugShowCheckedModeBanner: false,
      theme: VidaraTheme.darkTheme,
      home: const VideoDashboard(),
    );
  }
}
