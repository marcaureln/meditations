import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stoic/views/home.dart';
import 'package:stoic/views/add_quote.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/theme/app_localizations.dart';

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state._changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  @override
  void initState() {
    super.initState();
    _getLocal();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHome(),
        '/add_quote': (context) => AddQuote(),
      },
      theme: myTheme,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', ''), Locale('fr', '')],
    );
  }

  Future<String> _getLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('lang') != null && prefs.getString('lang').isNotEmpty) {
      _changeLanguage(Locale(prefs.getString('lang')));
    }
    return null;
  }

  _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
}
