import 'package:flutter/material.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    TextTheme _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Text(
          'Bookmarks',
          style: _textTheme.headline6,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: _theme.backgroundColor,
        ),
        onPressed: addQuote,
      ),
    );
  }

  void addQuote() {}
}
