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
  final _formKey = GlobalKey<FormState>();
  Quote quote = Quote('');

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    final Quote sendedQuote = ModalRoute.of(context).settings.arguments;

    if (sendedQuote != null) {
      quote = sendedQuote;
    }

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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    initialValue: quote.content,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('what_does_it_say'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'We cannot save an empty quote.';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      quote.content = text.trim();
                    },
                    onEditingComplete: () {
                      node.nextFocus();
                    },
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    initialValue: quote.author,
                    decoration: InputDecoration(
                      labelText:
                          '${AppLocalizations.of(context).translate('who_said_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      quote.author = (text != '') ? text.trim() : null;
                    },
                    onEditingComplete: () {
                      node.nextFocus();
                    },
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    initialValue: quote.source,
                    decoration: InputDecoration(
                      labelText:
                          '${AppLocalizations.of(context).translate('where_did_you_find_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      quote.source = (text != '') ? text.trim() : null;
                    },
                    onEditingComplete: () {
                      node.unfocus();
                      if (_formKey.currentState.validate()) _addQuote();
                    },
                  ),
                  RaisedButton(
                    elevation: 6,
                    color: myTheme.accentColor,
                    child: Text(
                      AppLocalizations.of(context).translate('save'),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) _addQuote();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addQuote() async {
    if (quote.id != null) {
      await AppDatabase.update('quotes', quote.id, quote.toMap());
    } else {
      var quoteId = await AppDatabase.insert('quotes', quote.toMap());
      quote.id = quoteId;
    }
    Navigator.pop(context, quote);
  }
}
