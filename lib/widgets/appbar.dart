import 'package:flutter/material.dart';
import 'package:stoic/theme/colors.dart';
import 'package:stoic/theme/theme.dart';

class MyAppBar extends AppBar {
  final String titleText;

  MyAppBar(this.titleText)
      : super(
          elevation: 0,
          backgroundColor: myTheme.scaffoldBackgroundColor,
          title: Text(
            titleText,
            style: TextStyle(color: MyColors.black),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: MyColors.black),
        );
}
