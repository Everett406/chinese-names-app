import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/data_service.dart';
import 'screens/home_screen.dart';
import 'screens/name_generator_screen.dart';
import 'screens/name_search_screen.dart';
import 'screens/surname_list_screen.dart';
import 'screens/idiom_dictionary_screen.dart';
import 'screens/ancient_names_screen.dart';
import 'screens/japanese_names_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => DataService()..init()),
      ],
      child: const ChineseNamesApp(),
    ),
  );
}

class ChineseNamesApp extends StatelessWidget {
  const ChineseNamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '萌名工具箱',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/generator': (context) => const NameGeneratorScreen(),
        '/search': (context) => const NameSearchScreen(),
        '/surnames': (context) => const SurnameListScreen(),
        '/idioms': (context) => const IdiomDictionaryScreen(),
        '/ancient': (context) => const AncientNamesScreen(),
        '/japanese': (context) => const JapaneseNamesScreen(),
      },
    );
  }
}
