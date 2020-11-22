import 'package:flutter/material.dart';

// import 'package:stoic/widgets/appbar.dart';
import 'package:stoic/views/bookmarks.dart';
import 'package:stoic/views/settings.dart';

class MyHome extends StatefulWidget {
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Map<int, Widget> _views = {0: Bookmarks(), 1: Settings()};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyAppBar,
      body: _views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _onItemTapped,
      ),
    );
  }
}
