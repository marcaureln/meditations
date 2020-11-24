import 'package:flutter/material.dart';

import 'package:stoic/views/home.dart';
import 'package:stoic/theme/theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHome(),
      },
      theme: myTheme,
    );
  }
}
