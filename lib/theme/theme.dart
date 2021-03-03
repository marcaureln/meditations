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
    //! White background + Black title and icons
    // color: Colors.white,
    // iconTheme: IconThemeData(color: Colors.black),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    padding: EdgeInsets.all(16.0),
    buttonColor: Colors.black,
    textTheme: ButtonTextTheme.primary,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.black,
    actionTextColor: Colors.white,
    behavior: SnackBarBehavior.floating,
  ),
);
