import 'package:flutter/material.dart';
import 'package:stoic/theme/text.dart';

ThemeData myTheme = ThemeData(
  primaryColor: Colors.black,
  accentColor: Colors.black,
  brightness: Brightness.light,
  textTheme: myTextTheme,
  appBarTheme: AppBarTheme(
    elevation: 4.0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.black,
      onPrimary: Colors.white,
      padding: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.black,
    actionTextColor: Colors.white,
    behavior: SnackBarBehavior.floating,
  ),
);
