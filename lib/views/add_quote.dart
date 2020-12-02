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
  Quote _quote;

  initState() {
    super.initState();
    _quote = Quote('');
  }

  @override
  Widget build(BuildContext context) {
    QuotesDao dao = QuotesDao();

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
          FocusScope.of(context).requestFocus(FocusNode());
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
                    // autofocus: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('what_does_it_say'),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.content = text;
                    }),
                TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                              .translate('who_said_it') +
                          ' (${AppLocalizations.of(context).translate('optional').toLowerCase()})',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.author = (text != '') ? text : null;
                    }),
                TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                              .translate('where_did_you_find_it') +
                          ' (${AppLocalizations.of(context).translate('optional').toLowerCase()})',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.source = (text != '') ? text : null;
                    }),
                Container(
                  child: RaisedButton(
                    elevation: 6,
                    color: myTheme.accentColor,
                    child: Text(
                      AppLocalizations.of(context).translate('save'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (_quote.content != '' && _quote.content != null) {
                        dao.insertQuote(_quote);
                        Navigator.pop(context);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
