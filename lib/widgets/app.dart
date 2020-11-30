import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:stoic/views/home.dart';
import 'package:stoic/views/add_quote.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/theme/app_localizations.dart';

class MyApp extends StatelessWidget {
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', ''), Locale('fr', '')],
    );
  }
}
