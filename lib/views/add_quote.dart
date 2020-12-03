import 'package:flutter/material.dart';

import 'package:stoic/db/quotes_dao.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  QuotesDao dao = QuotesDao();
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
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
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
                    _quote.content = text;
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
                    _quote.author = (text != '') ? text : null;
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
                    _quote.source = (text != '') ? text : null;
                  },
                  onEditingComplete: () {
                    node.unfocus();
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

  void _addQuote() {
    dao.insertQuote(_quote);
    Navigator.pop(context);
  }
}
