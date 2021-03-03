import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:stoic/db/database.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final _formKey = GlobalKey<FormState>();
  final _quoteContentController = TextEditingController();
  Quote quote = Quote('');

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    final Quote sendedQuote = ModalRoute.of(context).settings.arguments;

    if (sendedQuote != null) {
      quote = sendedQuote;
      _quoteContentController.text = quote.content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('add_quote'))),
      body: GestureDetector(
        onTap: () {
          node.requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 80,
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _quoteContentController,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('what_does_it_say'),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.paste),
                        onPressed: _pasteFromClipboard,
                      ),
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return AppLocalizations.of(context).translate('we_cannot_save_quote');
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: RaisedButton.icon(
                      icon: Icon(Icons.save),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      label: Text(AppLocalizations.of(context).translate('save')),
                      onPressed: () {
                        if (_formKey.currentState.validate()) _addQuote();
                      },
                    ),
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

  void _pasteFromClipboard() {
    FlutterClipboard.paste().then((value) {
      quote.content = value.trim();
      setState(() {
        _quoteContentController.text = value;
      });
    });
  }
}
