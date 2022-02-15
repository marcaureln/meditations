import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/views/add_quote.dart';
import 'package:stoic/views/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meditations',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHome(),
        '/add_quote': (context) => AddQuote(Quote('')),
      },
      theme: myTheme,
      // locale: Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
    );
  }
}
