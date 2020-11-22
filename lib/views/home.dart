import 'package:flutter/material.dart';

import 'package:stoic/widgets/appbar.dart';

class MyHome extends StatefulWidget {
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar,
      body: null,
      // bottomNavigationBar: BottomNavigationBar(),
    );
  }
}
