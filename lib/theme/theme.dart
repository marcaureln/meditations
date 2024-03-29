import 'package:flutter/material.dart';
import 'package:stoic/theme/color.dart';
import 'package:stoic/theme/text.dart';

ThemeData myTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: primaryBlack,
  textTheme: openSans,
  appBarTheme: AppBarTheme(
    elevation: 4.0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
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
