import 'package:flutter/material.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/academy_branch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await MobileAds.instance.initialize();

  runApp(const GeniusAcademyApp());
}

class GeniusAcademyApp extends StatelessWidget {
  const GeniusAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedBlue = Color(0xFF1565C0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Genius Academy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AcademyBranchScreen(),
    );
  }
}
