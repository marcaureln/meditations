import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

TextTheme openSans = TextTheme(
  headline1: GoogleFonts.openSans(fontSize: 92, fontWeight: FontWeight.w300, letterSpacing: -1.5),
  headline2: GoogleFonts.openSans(fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
  headline3: GoogleFonts.openSans(fontSize: 46, fontWeight: FontWeight.w400),
  headline4: GoogleFonts.openSans(fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headline5: GoogleFonts.openSans(fontSize: 23, fontWeight: FontWeight.w400),
  headline6: GoogleFonts.openSans(fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  subtitle1: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  subtitle2: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyText1: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyText2: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  button: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.25),
  caption: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  overline: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);

TextTheme ptSerif = TextTheme(
  headline1: GoogleFonts.ptSerif(fontSize: 100, fontWeight: FontWeight.w300, letterSpacing: -1.5),
  headline2: GoogleFonts.ptSerif(fontSize: 62, fontWeight: FontWeight.w300, letterSpacing: -0.5),
  headline3: GoogleFonts.ptSerif(fontSize: 50, fontWeight: FontWeight.w400),
  headline4: GoogleFonts.ptSerif(fontSize: 35, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headline5: GoogleFonts.ptSerif(fontSize: 25, fontWeight: FontWeight.w400),
  headline6: GoogleFonts.ptSerif(fontSize: 21, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  subtitle1: GoogleFonts.ptSerif(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  subtitle2: GoogleFonts.ptSerif(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyText1: GoogleFonts.ptSerif(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyText2: GoogleFonts.ptSerif(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  button: GoogleFonts.ptSerif(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1.25),
  caption: GoogleFonts.ptSerif(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  overline: GoogleFonts.ptSerif(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);

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
