import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'screens/name_search_screen.dart';
import 'screens/name_generator_screen.dart';
import 'screens/surname_list_screen.dart';
import 'screens/idiom_dictionary_screen.dart';
import 'screens/ancient_names_screen.dart';
import 'screens/japanese_names_screen.dart';
import 'screens/english_names_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChineseNamesApp());
}

class ChineseNamesApp extends StatelessWidget {
  const ChineseNamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中文名字语料库',
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,

      // 国际化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),

      // 路由表
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/generator': (context) => const NameGeneratorScreen(),
        '/search': (context) => const NameSearchScreen(),
        '/surnames': (context) => const SurnameListScreen(),
        '/idioms': (context) => const IdiomDictionaryScreen(),
        '/ancient': (context) => const AncientNamesScreen(),
        '/japanese': (context) => const JapaneseNamesScreen(),
        '/english': (context) => const EnglishNamesScreen(),
      },
    );
  }
}
