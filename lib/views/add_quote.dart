import 'package:flutter/material.dart';
import 'package:stoic/db/database.dart';

import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  Quote _quote;
  bool isQuoteContentEmpty = true;

  void initState() {
    super.initState();
    _quote = Quote('');
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('add_quote')),
        backgroundColor: myTheme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, null);
            }),
      ),
      body: GestureDetector(
        onTap: () {
          node.requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * .5,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('what_does_it_say'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    _quote.content = text.trim();
                    setState(() {
                      isQuoteContentEmpty = (text.isNotEmpty) ? false : true;
                    });
                  },
                  onEditingComplete: () {
                    node.nextFocus();
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).translate('who_said_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    _quote.author = (text != '') ? text.trim() : null;
                  },
                  onEditingComplete: () {
                    node.nextFocus();
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).translate('where_did_you_find_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    _quote.source = (text != '') ? text.trim() : null;
                  },
                  onEditingComplete: () {
                    node.unfocus();
                    (isQuoteContentEmpty) ? null : _addQuote();
                  },
                ),
                Container(
                  child: RaisedButton(
                    elevation: 6,
                    color: myTheme.accentColor,
                    child: Text(
                      AppLocalizations.of(context).translate('save'),
                    ),
                    onPressed: (isQuoteContentEmpty) ? null : _addQuote,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addQuote() async {
    var _quoteId = await AppDatabase.insert('quotes', _quote.toMap());
    _quote.id = _quoteId;
    Navigator.pop(context, _quote);
  }
}
