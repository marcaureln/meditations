import 'package:flutter/material.dart';

import 'package:clipboard/clipboard.dart';
import 'package:stoic/db/database.dart';

import 'package:stoic/theme/theme.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/appbar.dart';
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
      appBar: MyAppBar(
        AppLocalizations.of(context).translate('bookmarks_appbar_title'),
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
                      onTap: () {
                        _showActions(quote);
                      },
                      onLongPress: () {
                        _saveToClipboard(quote);
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
                                    : AppLocalizations.of(context).translate('anonymous'),
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
    final index = quotes.indexOf(quote);

    setState(() {
      quotes.remove(quote);
    });
    Scaffold.of(context)
        .showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(AppLocalizations.of(context).translate('quote_removed')),
            action: SnackBarAction(
              label: AppLocalizations.of(context).translate('undo'),
              onPressed: () {
                setState(() {
                  quotes.insert(index, quote);
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

  _openAddQuotePage({Quote quote}) async {
    var returnedQuote = await Navigator.pushNamed(context, '/add_quote', arguments: quote);
    if (returnedQuote != null) {
      if (quote != null) {
        setState(() {
          quote = returnedQuote;
        });
      } else {
        setState(() {
          quotes.add(returnedQuote);
        });
      }
    }
  }

  _showActions(Quote quote) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(8),
            children: [
              Center(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.mode_edit),
                        onPressed: () {
                          Navigator.pop(context);
                          _openAddQuotePage(quote: quote);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Navigator.pop(context);
                          _removeQuote(quote);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.content_copy),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveToClipboard(quote);
                        },
                      ),
                    ],
                  ),
                  OutlineButton.icon(
                    icon: Icon(Icons.help),
                    label: Text(AppLocalizations.of(context).translate('help')),
                    onPressed: () {
                      Navigator.pop(context);
                      _openWebView('https://marcaureln.com');
                    },
                  )
                ],
              )),
            ],
          );
        });
  }

  _openWebView(url) {
    Navigator.pushNamed(context, '/web_view', arguments: url);
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
          content: Text(AppLocalizations.of(context).translate('copied_to_clipboard')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
