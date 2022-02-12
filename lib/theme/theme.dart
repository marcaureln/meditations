import 'package:flutter/material.dart';
import 'package:stoic/theme/color.dart';
import 'package:stoic/theme/text.dart';

ThemeData myTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: primaryBlack,
  textTheme: openSans,
  appBarTheme: const AppBarTheme(
    elevation: 4.0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black,
    actionTextColor: Colors.white,
    behavior: SnackBarBehavior.floating,
  ),
);
