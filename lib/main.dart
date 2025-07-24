import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/canteen_queue_page.dart';

void main() {
  runApp(const ByteBitesApp());
}

class ByteBitesApp extends StatefulWidget {
  const ByteBitesApp({super.key});

  @override
  State<ByteBitesApp> createState() => ByteBitesAppState();
}

class ByteBitesAppState extends State<ByteBitesApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('currentUsername');
    if (currentUsername != null) {
      final savedLanguage = prefs.getString('language_$currentUsername');
      if (savedLanguage != null) {
        setState(() {
          _locale = Locale(savedLanguage);
        });
      }
    }
  }

  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteBites',
      theme: ThemeData.dark(),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese
      ],
      home: LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/canteen_queue': (context) => CanteenQueuePage(),
      },
    );
  }
}

class Vendor {
  final String id;
  final String name;
  final String description;
  final String address;
  final String openingHours;
  final String logoUrl;
  // ...
  Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.openingHours,
    required this.logoUrl,
    // ...
  });
}
