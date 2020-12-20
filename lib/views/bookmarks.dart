import 'package:flutter/material.dart';

import 'package:clipboard/clipboard.dart';
import 'package:stoic/db/database.dart';

import 'package:stoic/theme/theme.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/no_data.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<Quote> quotes;

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
        title: Text(
            AppLocalizations.of(context).translate('bookmarks_appbar_title')),
        centerTitle: true,
      ),
      body: (quotes.isEmpty)
          ? NoData()
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                Quote quote = quotes[index];

                return Dismissible(
                  key: ValueKey(quote.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
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
                    ),
                  ),
                  child: Card(
                    child: InkWell(
                      onLongPress: () {
                        _saveToClipboard(quote);
                      },
                      onDoubleTap: () {
                        print('double tap detected');
                      },
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
                                (quote.author != null)
                                    ? quote.author
                                    : AppLocalizations.of(context)
                                        .translate('anonymous'),
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: myTheme.scaffoldBackgroundColor,
        ),
        onPressed: _openAddQuotePage,
      ),
    );
  }

  _fetchQuotes() async {
    List<Quote> records = [];
    await AppDatabase.selectAll('quotes').then((data) {
      for (var snapshot in data) {
        records.add(Quote.fromMap(snapshot.key, snapshot.value));
      }
    });

    setState(() {
      quotes = records;
    });
  }

  _removeQuote(Quote quote) {
    setState(() {
      quotes.remove(quote);
    });
    Scaffold.of(context)
        .showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content:
                Text(AppLocalizations.of(context).translate('quote_removed')),
            action: SnackBarAction(
              label: AppLocalizations.of(context).translate('undo'),
              onPressed: () {
                setState(() {
                  quotes.insert(0, quote);
                });
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        AppDatabase.delete('quotes', quote.id);
      }
    });
  }

  _openAddQuotePage() async {
    var returnedQuote = await Navigator.pushNamed(context, '/add_quote');
    if (returnedQuote != null) {
      setState(() {
        quotes.add(returnedQuote);
      });
    }
  }

  _saveToClipboard(Quote quote) {
    var text = '"${quote.content}"';

    if (quote.source != null) {
      text += ' ${quote.source}';
      if (quote.author != null) {
        text += ', ${quote.author}';
      }
    } else if (quote.author != null) {
      text += ' ${quote.author}';
    }

    FlutterClipboard.copy(text).then((_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('copied_to_clipboard')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
