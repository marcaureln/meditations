import 'package:flutter/material.dart';

import 'package:stoic/theme/theme.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/no_data.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<Quote> _quotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: myTheme.scaffoldBackgroundColor,
        title: Text('Your quotes'),
        centerTitle: true,
      ),
      body: (_quotes.isEmpty)
          ? NoData()
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _quotes.length,
              itemBuilder: (BuildContext context, int index) {
                String content = _quotes[index].content;
                String author = _quotes[index].author;
                String source = _quotes[index].source;

                return Dismissible(
                  key: ValueKey(content),
                  direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      _quotes.removeAt(index);
                    });
                  },
                  background: Card(
                      color: Color(0xffd72323),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: myTheme.scaffoldBackgroundColor,
                          ),
                          Container(width: 8),
                        ],
                      )),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Text(
                              '"$content"',
                              style: myTheme.textTheme.subtitle1,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              author,
                              style: myTheme.textTheme.subtitle2,
                            ),
                          ),
                          if (source != null)
                            Container(
                              width: double.infinity,
                              child: Text(source),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: myTheme.scaffoldBackgroundColor,
        ),
        onPressed: addQuote,
      ),
    );
  }

  void addQuote() {
    Quote _quote = Quote('');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text('Add a quote',
                      style: myTheme.textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.bold)),
                  Container(
                      padding: EdgeInsets.all(8),
                      child: Column(children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'What does it say',
                          ),
                          onChanged: (String text) => _quote.content = text,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Who said it (optional)',
                          ),
                          onChanged: (String text) =>
                              _quote.author = (text != '') ? text : null,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Where did you find it (optional)',
                          ),
                          onChanged: (String text) =>
                              _quote.source = (text != '') ? text : null,
                        ),
                      ])),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      RaisedButton(
                          color: myTheme.accentColor,
                          child: Text('Add',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              _quotes.add(_quote);
                            });
                            Navigator.pop(context);
                          }),
                    ],
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
