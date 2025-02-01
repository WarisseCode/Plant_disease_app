// main.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'prediction_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations', // Chemin des fichiers de traduction
      fallbackLocale: const Locale('en'),
      child: const PlantDiseaseApp(),
    ),
  );
}

class PlantDiseaseApp extends StatelessWidget {
  const PlantDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Plant Disease'.tr(), // Utilisation des traductions
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: HomePage(),
          initialRoute: '/',
          routes: {
            '/predict': (context) => PredictionPage(),
            '/history': (context) => HistoryPage(),
            '/settings': (context) => SettingsPage(), // Nouvelle route pour les paramètres
          },
        );
      },
    );
  }
}
