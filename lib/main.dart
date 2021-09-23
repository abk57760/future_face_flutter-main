import 'package:flutter/material.dart';
import 'package:future_face_app/localization/demo_localization.dart';
import 'screens/splash.dart';
import 'screens/import.dart';
import 'screens/result.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Future Face',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('pt', 'PT'),
        Locale('es', 'ES'),
        Locale('zh', 'CN'),
        Locale('ar', 'SA'),
      ],
      localizationsDelegates: const [
        DemoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode &&
              locale.countryCode == deviceLocale!.countryCode) {
            return deviceLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/import': (context) => const ImportScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
