import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedValues;

  AppLocalizations(this.locale);

  // ignore: prefer_constructors_over_static_methods
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en', ''));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    final String jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');
    final Map jsonMap = json.decode(jsonString) as Map;

    _localizedValues = jsonMap.map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });

    return true;
  }

  String translate(String key) => _localizedValues[key] ?? 'Missing translation: $key';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
