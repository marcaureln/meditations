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
          : ListView.separated(
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
                  child: Container(
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
              separatorBuilder: (context, _) => const Divider(height: 12),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context).translate('add_quote'),
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
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            children: [
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    tooltip: AppLocalizations.of(context).translate('modify'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openAddQuotePage(quote: quote);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    tooltip: AppLocalizations.of(context).translate('remove'),
                    onPressed: () {
                      Navigator.pop(context);
                      _removeQuote(quote);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    tooltip: AppLocalizations.of(context).translate('copy'),
                    onPressed: () {
                      Navigator.pop(context);
                      _saveToClipboard(quote);
                    },
                  ),
                ],
              )),
            ],
          );
        });
  }

  _saveToClipboard(Quote quote) {
    FlutterClipboard.copy(quote.toString()).then((_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('copied_to_clipboard')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
