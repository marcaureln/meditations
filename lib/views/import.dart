import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stoic/db/quote_dao.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/quote_tile.dart';

class Import extends StatefulWidget {
  final String raw;

  Import({@required this.raw});

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Future _future;
  Map _quotes;
  bool _selectAll;

  @override
  void initState() {
    super.initState();
    _future = _parseJson();
    _selectAll = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import'),
        actions: [
          IconButton(onPressed: _import, icon: Icon(Icons.done)),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2.0),
                  const SizedBox(height: 8),
                  Text('Parsing file...'),
                ],
              ),
            );
          }

          _quotes = snapshot.data;
          List keys = _quotes.keys.toList();

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _quotes.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                var noSelected = _quotes.values.where((value) => value == true).length;

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            for (var key in keys) {
                              _quotes[key] = value;
                              _selectAll = value;
                            }
                          });
                        },
                      ),
                      Text(
                        'Select all',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const VerticalDivider(indent: 8, endIndent: 8),
                      Text('$noSelected ${noSelected > 1 ? 'quotes' : 'quote'} selected'),
                    ],
                  ),
                );
              }

              var quote = keys[i - 1];

              return InkWell(
                onTap: () {
                  setState(() {
                    _quotes[quote] = !_quotes[quote];
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _quotes[quote],
                      onChanged: (value) {
                        setState(() {
                          _quotes[quote] = value;
                        });
                      },
                    ),
                    Expanded(child: QuoteTile(context: context, quote: quote)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<Quote, bool>> _parseJson() async {
    bool contains(List<Quote> list, Quote element) {
      for (var e in list) {
        if (e.equals(element)) return true;
      }
      return false;
    }

    final quoteDao = QuoteDAO();
    List<Quote> localStore = await quoteDao.selectAll();

    final List json = jsonDecode(widget.raw);
    Map<Quote, bool> quotes = {};
    for (var record in json) {
      var map = Map<String, String>.from(record);
      var quote = Quote.fromMap(null, map);
      if (contains(localStore, quote)) {
        quotes[quote] = false;
        if (_selectAll) _selectAll = false;
      } else {
        quotes[quote] = true;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplicates are not checked')));

    return quotes;
  }

  void _import() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Container(
              height: 160,
              width: MediaQuery.of(context).size.width * .8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                    const SizedBox(height: 8),
                    Text('Importing quotes...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    final quoteDao = QuoteDAO();
    var count = 0;
    for (var entry in _quotes.entries) {
      if (entry.value) {
        quoteDao.insert(entry.key);
        count++;
      }
    }

    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Done, $count quote(s) imported')));
  }
}
