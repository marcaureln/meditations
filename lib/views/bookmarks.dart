import 'package:flutter/material.dart';

import 'package:stoic/theme/theme.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/db/quotes_dao.dart';
import 'package:stoic/widgets/no_data.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  QuotesDao dao = QuotesDao();
  List<Quote> quotes;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    if (quotes == null) {
      _fetchQuotes();
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: myTheme.scaffoldBackgroundColor,
        title: Text('Your quotes'),
        centerTitle: true,
      ),
      body: (quotes.length == 0)
          ? NoData()
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: quotes.length,
              itemBuilder: (BuildContext context, int index) {
                print('listview built');
                Quote quote = quotes[index];

                return Dismissible(
                  key: ValueKey(quote.content),
                  direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    _removeQuote(quote);
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
                              '"${quote.content}"',
                              style: myTheme.textTheme.subtitle1,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              quote.author,
                              style: myTheme.textTheme.subtitle2,
                            ),
                          ),
                          if (quote.source != null)
                            Container(
                              width: double.infinity,
                              child: Text(quote.source),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: myTheme.scaffoldBackgroundColor,
        ),
        onPressed: addQuoteDialog,
      ),
    );
  }

  // TODO: move addquote dialog to a dedicated page
  void addQuoteDialog() {
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
                            _addQuote(_quote);
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

  _fetchQuotes() async {
    await dao.getAllQuotes().then((data) {
      setState(() {
        quotes = data;
      });
      print('Last delivery:\n$quotes');
    });
  }

  _removeQuote(Quote quote) {
    print('Removed: $quote');
    dao.deleteQuote(quote);
    setState(() => quotes.remove(quote));
    _fetchQuotes();
  }

  _addQuote(Quote quote) {
    print('Added: $quote');
    dao.insertQuote(quote);
    // setState(() => quotes.add(quote));
    _fetchQuotes();
  }
}
