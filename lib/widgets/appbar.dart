import 'package:flutter/material.dart';
import 'package:stoic/theme/theme.dart';

class MyAppBar extends AppBar {
  final String titleText;

  MyAppBar(this.titleText)
      : super(
          elevation: 0,
          backgroundColor: myTheme.scaffoldBackgroundColor,
          title: Text(titleText),
          centerTitle: true,
        );
}
