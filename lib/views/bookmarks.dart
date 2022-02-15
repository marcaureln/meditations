import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share/share.dart';
import 'package:stoic/db/quote_dao.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/views/add_quote.dart';
import 'package:stoic/views/search.dart';
import 'package:stoic/widgets/no_data.dart';
import 'package:stoic/widgets/quote_tile.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<Quote>? quotes;
  final _quoteDao = QuoteDAO();
  final _scrollController = ScrollController();
  late SortBy _sortOrder;
  late bool _isFabVisible;
  late bool _bottomReached;

  final Map<SortBy, String> _sortOptions = {
    SortBy.author: 'A-Z (author)',
    SortBy.source: 'A-Z (source)',
    SortBy.newest: 'Recently added',
    SortBy.none: 'Default',
  };

  @override
  void initState() {
    super.initState();
    _isFabVisible = true;
    _bottomReached = false;
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    if (quotes == null) {
      _fetchQuotes();
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('bookmarks_appbar_title')),
        actions: [
          IconButton(onPressed: _search, icon: const Icon(Icons.search)),
        ],
      ),
      body: (quotes?.isEmpty == true)
          ? NoData()
          : Scrollbar(
              controller: _scrollController,
              interactive: true,
              radius: const Radius.circular(24),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 128),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: quotes!.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _selectSortOrder,
                          icon: const Icon(Icons.import_export),
                          label: Text(_sortOptions[_sortOrder] ?? ''),
                        )
                      ],
                    );
                  }

                  final Quote quote = quotes![index - 1];

                  return Dismissible(
                    key: ValueKey(quote.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      _removeQuote(quote);
                    },
                    background: Card(
                      color: const Color(0xffd72323),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    child: QuoteTile(
                      context: context,
                      quote: quote,
                      onTap: () {
                        _showActions(quote);
                      },
                      onLongPress: () {
                        _saveToClipboard(quote);
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  if (index == 0) return Container();
                  return const Divider(height: 12);
                },
              ),
            ),
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: (_bottomReached == false)
            ? FloatingActionButton(
                tooltip: AppLocalizations.of(context).translate('add_quote'),
                onPressed: _openAddQuotePage,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : FloatingActionButton(
                tooltip: AppLocalizations.of(context).translate('move_top'),
                onPressed: _moveTop,
                child: Icon(
                  Icons.arrow_upward,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
      ),
    );
  }

  Future<void> _fetchQuotes() async {
    final List<Quote> records = await _quoteDao.selectAll();

    final SortBy sortOrder = await _getSortOrder();
    _sort(records, sortOrder);

    setState(() {
      _sortOrder = sortOrder;
      quotes = records;
    });
  }

  void _removeQuote(Quote quote) {
    _quoteDao.delete(quote);

    setState(() {
      _isFabVisible = false;
      quotes!.remove(quote);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(AppLocalizations.of(context).translate('quote_removed')),
            action: SnackBarAction(
              label: AppLocalizations.of(context).translate('undo'),
              onPressed: () {
                _quoteDao.insert(quote);
                setState(() {
                  quotes!.add(quote);
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

  Future<void> _openAddQuotePage({Quote? quote}) async {
    final Quote? returnedQuote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddQuote(quote ?? Quote(''))),
    );

    if (returnedQuote != null) {
      setState(() {
        if (quote != null) {
          // ignore: parameter_assignments
          quote = returnedQuote;
        } else {
          quotes!.add(returnedQuote);
          _sort(quotes!, _sortOrder);
        }
      });
    }
  }

  void _showActions(Quote quote) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      elevation: 8.0,
      context: context,
      builder: (context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuoteTile(context: context, quote: quote),
          ),
          const Divider(),
          ListTile(
            dense: true,
            leading: const Icon(Icons.share),
            title: Text(
              AppLocalizations.of(context).translate('share'),
              style: textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              Share.share(quote.toString());
            },
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.content_copy),
            title: Text(
              AppLocalizations.of(context).translate('copy'),
              style: textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              _saveToClipboard(quote);
            },
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.mode_edit),
            title: Text(
              AppLocalizations.of(context).translate('modify'),
              style: textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pop(context);
              _openAddQuotePage(quote: quote);
            },
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.delete),
            title: Text(
              AppLocalizations.of(context).translate('remove'),
              style: textTheme.bodyText1,
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

  void _saveToClipboard(Quote quote) {
    setState(() {
      _isFabVisible = false;
    });
    FlutterClipboard.copy(quote.toString()).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('copied_to_clipboard')),
              duration: const Duration(seconds: 2),
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
    final box = await Hive.openBox('preferences');
    final saved = box.get('sortorder');
    return SortBy.values.firstWhere((element) => element.toString() == saved, orElse: () => SortBy.none);
  }

  Future<void> _saveSortOrder(SortBy sortOrder) async {
    final box = await Hive.openBox('preferences');
    box.put('sortorder', sortOrder.toString());
    _sortOrder = sortOrder;
  }

  void _selectSortOrder() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _sortOptions.length,
          itemBuilder: (context, index) {
            final option = _sortOptions.keys.toList()[index];

            return ListTile(
              onTap: () {
                _saveSortOrder(option);
                setState(() {
                  _sort(quotes!, option);
                });
                Navigator.pop(context);
              },
              title: Text(_sortOptions[option] ?? ''),
              trailing: option == _sortOrder ? const Icon(Icons.check) : null,
            );
          },
        );
      },
    );
  }

  void _sort(List<Quote> quotes, SortBy sortOrder) {
    switch (sortOrder) {
      case SortBy.author:
        quotes.sort((a, b) => (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case SortBy.source:
        quotes.sort((a, b) => (a.source ?? '').compareTo(b.source ?? ''));
        break;
      case SortBy.newest:
        quotes.sort((a, b) => b.id! - a.id!);
        break;
      case SortBy.none:
        quotes.sort((a, b) => a.id! - b.id!);
        break;
      default:
    }
  }

  Future<void> _search() async {
    final result = await showSearch<Quote>(context: context, delegate: QuoteSearchDelegate(quotes!));
    if (result != null) {
      _showActions(result);
    }
  }

  void _moveTop() {
    _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.ease);
  }

  void _scrollListener() {
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
