import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic/db/database.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/views/search.dart';
import 'package:stoic/widgets/no_data.dart';

class Bookmarks extends StatefulWidget {
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<Quote> quotes;
  final _scrollController = ScrollController();
  SortBy _sortOrder;
  bool _isFabVisible;
  bool _bottomReached;

  @override
  void initState() {
    super.initState();
    _isFabVisible = true;
    _bottomReached = false;
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (quotes == null) {
      _fetchQuotes();
      return Center(child: CircularProgressIndicator(strokeWidth: 2.0));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('bookmarks_appbar_title')),
        actions: [
          IconButton(onPressed: _search, icon: Icon(Icons.search)),
          PopupMenuButton<SortBy>(
            icon: Icon(Icons.import_export),
            initialValue: _sortOrder,
            onSelected: (sortOrder) {
              _saveSortOrder(sortOrder);
              setState(() {
                _sort(quotes, sortOrder);
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortBy.author,
                child: Text('A-Z (author)'),
              ),
              PopupMenuItem(
                value: SortBy.source,
                child: Text('A-Z (source)'),
              ),
              PopupMenuItem(
                value: SortBy.newest,
                child: Text('Newest'),
              ),
              PopupMenuItem(
                value: SortBy.none,
                child: Text('Default'),
              ),
            ],
          ),
        ],
      ),
      body: (quotes.isEmpty)
          ? NoData()
          : ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 128),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                          color: theme.scaffoldBackgroundColor,
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
                                style: theme.textTheme.subtitle1,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(
                                (quote.author != null)
                                    ? quote.author
                                    : AppLocalizations.of(context).translate('anonymous'),
                                style: theme.textTheme.subtitle2,
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
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: (_bottomReached == false)
            ? FloatingActionButton(
                tooltip: AppLocalizations.of(context).translate('add_quote'),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                onPressed: _openAddQuotePage,
              )
            : FloatingActionButton(
                tooltip: AppLocalizations.of(context).translate('move_top'),
                child: Icon(
                  Icons.arrow_upward,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                onPressed: _moveTop,
              ),
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

    SortBy sortOrder = await _getSortOrder();
    _sort(records, sortOrder);

    setState(() {
      _sortOrder = sortOrder;
      quotes = records;
    });
  }

  _removeQuote(Quote quote) {
    AppDatabase.delete('quotes', quote.id);

    setState(() {
      _isFabVisible = false;
      quotes.remove(quote);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(AppLocalizations.of(context).translate('quote_removed')),
            action: SnackBarAction(
              label: AppLocalizations.of(context).translate('undo'),
              onPressed: () {
                AppDatabase.insert('quotes', quote.toMap());
                setState(() {
                  quotes.add(quote);
                });
              },
            ),
          ),
        )
        .closed
        .then((_) {
      setState(() {
        _isFabVisible = true;
      });
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
          _sort(quotes, _sortOrder);
        });
      }
    }
  }

  _showActions(Quote quote) {
    ThemeData theme = Theme.of(context);

    showModalBottomSheet(
      elevation: 8.0,
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(quote.toString()),
          ),
          const Divider(),
          ListTile(
            dense: true,
            leading: Icon(Icons.share),
            title: Text(
              AppLocalizations.of(context).translate('share'),
              style: theme.textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              Share.share(quote.toString());
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.content_copy),
            title: Text(
              AppLocalizations.of(context).translate('copy'),
              style: theme.textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              _saveToClipboard(quote);
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.mode_edit),
            title: Text(
              AppLocalizations.of(context).translate('modify'),
              style: theme.textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              _openAddQuotePage(quote: quote);
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.delete),
            title: Text(
              AppLocalizations.of(context).translate('remove'),
              style: theme.textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              _removeQuote(quote);
            },
          ),
        ],
      ),
    );
  }

  _saveToClipboard(Quote quote) {
    setState(() {
      _isFabVisible = false;
    });
    FlutterClipboard.copy(quote.toString()).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('copied_to_clipboard')),
              duration: Duration(seconds: 2),
            ),
          )
          .closed
          .then((_) {
        setState(() {
          _isFabVisible = true;
        });
      });
    });
  }

  Future<SortBy> _getSortOrder() async {
    var sortOrder;
    var prefs = await SharedPreferences.getInstance();
    var saved = prefs.getString('sortorder');
    for (SortBy element in SortBy.values) {
      if (element.toString() == saved) {
        sortOrder = element;
        break;
      }
    }
    return sortOrder ?? SortBy.none;
  }

  _saveSortOrder(SortBy sortOrder) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('sortorder', sortOrder.toString());
    _sortOrder = sortOrder;
  }

  _sort(List<Quote> quotes, SortBy sortOrder) {
    switch (sortOrder) {
      case SortBy.author:
        quotes.sort((a, b) => (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case SortBy.source:
        quotes.sort((a, b) => (a.source ?? '').compareTo(b.source ?? ''));
        break;
      case SortBy.newest:
        quotes.sort((a, b) => b.id - a.id);
        break;
      case SortBy.none:
        quotes.sort((a, b) => a.id - b.id);
        break;
      default:
    }
  }

  _search() {
    showSearch(context: context, delegate: QuoteSearchDelegate(quotes));
  }

  _moveTop() {
    _scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.ease);
  }

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      if (_bottomReached == false) {
        setState(() {
          _bottomReached = true;
        });
      }
    } else if (_bottomReached == true) {
      setState(() {
        _bottomReached = false;
      });
    }
  }
}

enum SortBy { author, source, newest, none }
