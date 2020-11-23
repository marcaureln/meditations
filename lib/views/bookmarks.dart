import 'package:flutter/material.dart';

import 'package:stoic/theme/text.dart';
import 'package:stoic/models/quote.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<Quote> _quotes = [
    Quote("Vivre, c'est s'adapter.", source: 'Hippie', author: 'Paulo Coelho'),
    Quote('Impossible is for the unwilling', author: 'John Keats'),
    Quote(
        'My biggest fear is that eventually you will see me the way I see myself.',
        source: 'Your Life User Manual '),
    Quote('No pressure, no diamonds.', author: 'Thomas Carlyle'),
    Quote(
        'It’s a good poem if I’m a different person when I’m finished reading it.')
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    TextTheme _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _theme.scaffoldBackgroundColor,
        title: Text('Your quotes'),
        centerTitle: true,
      ),
      body: ListView.builder(
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
                          color: _theme.scaffoldBackgroundColor,
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
                          style: _textTheme.subtitle1,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          author,
                          style: _textTheme.subtitle2,
                        ),
                      ),
                      if (source != null)
                        Container(
                          width: double.infinity,
                          child: Text(source),
                        ),
                    ],
                  ),
                )));
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: _theme.scaffoldBackgroundColor,
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
                child: Column(children: [
                  Text('Add a quote',
                      style: myTextTheme.bodyText1
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
                          color: Color(0xff4ecdc4),
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
                ]),
              )
            ],
          );
        });
  }
}
