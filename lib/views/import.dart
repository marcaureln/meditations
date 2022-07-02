import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stoic/db/quote_repository.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/quote_tile.dart';

class Import extends StatefulWidget {
  final String raw;

  const Import({required this.raw});

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  late Future<Map<Quote, bool>> _quotesToImport;
  late bool _selectAll;

  @override
  void initState() {
    super.initState();
    _quotesToImport = _parseJson(widget.raw);
    _selectAll = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('import')),
        actions: [
          IconButton(
            onPressed: () async {
              _import(await _quotesToImport);
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: FutureBuilder<Map<Quote, bool>>(
        future: _quotesToImport,
        builder: (context, AsyncSnapshot<Map<Quote, bool>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.0),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).translate('parsing_file')),
                ],
              ),
            );
          }

          final Map<Quote, bool> quotesToImport = snapshot.data!;
          final List<Quote> quotes = quotesToImport.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: quotesToImport.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                final noSelected = quotesToImport.values.where((value) => value == true).length;

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            for (final key in quotes) {
                              quotesToImport[key] = value!;
                              _selectAll = value;
                            }
                          });
                        },
                      ),
                      Text(
                        AppLocalizations.of(context).translate('select_all'),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const VerticalDivider(indent: 8, endIndent: 8),
                      if (noSelected > 1)
                        Text('$noSelected ${AppLocalizations.of(context).translate('many_quote_selected')}')
                      else
                        Text('$noSelected ${AppLocalizations.of(context).translate('one_quote_selected')}')
                    ],
                  ),
                );
              }

              final quote = quotes[i - 1];

              return InkWell(
                onTap: () {
                  setState(() {
                    quotesToImport[quote] = !(quotesToImport[quote] == true);
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: quotesToImport[quote],
                      onChanged: (value) {
                        setState(() {
                          quotesToImport[quote] = value!;
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

  Future<Map<Quote, bool>> _parseJson(String rawJson) async {
    final quoteRepository = QuoteRepository();
    final Map<Quote, bool> quotesToImport = {};
    final List<Quote> localQuotes = await quoteRepository.selectAll();
    final List jsonList = jsonDecode(rawJson) as List;

    for (final entry in jsonList) {
      final map = Map<String, dynamic>.from(entry as Map);
      final quote = Quote.fromMap(null, map, hasTimestamp: false);

      if (localQuotes.any((element) => element.equals(quote))) {
        quotesToImport[quote] = false;
        if (_selectAll) _selectAll = false;
      } else {
        quotesToImport[quote] = true;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('avoid_duplicates'))),
      );
    }

    return quotesToImport;
  }

  void _import(Map<Quote, bool> quotes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: SizedBox(
              height: 160,
              width: MediaQuery.of(context).size.width * .8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context).translate('import_in_progress')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    final quoteRepository = QuoteRepository();
    var count = 0;
    for (final entry in quotes.entries) {
      if (entry.value) {
        quoteRepository.insert(entry.key);
        count++;
      }
    }

    Navigator.popUntil(context, ModalRoute.withName('/'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context).translate('done')}, $count ${AppLocalizations.of(context).translate('import_count')}',
        ),
      ),
    );
  }
}
