import 'package:flutter/material.dart';

import 'package:stoic/views/home.dart';
import 'package:stoic/theme/text.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      // home: MyHome(),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHome(),
      },
      theme: ThemeData(textTheme: myTextTheme),
    );
  }
}
