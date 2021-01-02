import 'package:flutter/material.dart';
import 'package:stoic/theme/colors.dart';

import 'package:stoic/theme/text.dart';

ThemeData myTheme = ThemeData(
  primaryColor: MyColors.black,
  accentColor: MyColors.darkCharcoal,
  scaffoldBackgroundColor: MyColors.white,
  snackBarTheme: SnackBarThemeData(actionTextColor: MyColors.white),
  textTheme: myTextTheme,
);
