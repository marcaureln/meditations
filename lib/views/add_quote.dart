import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Quote _quote = Quote('');
  bool _autoPasteEnabled;
  bool _alreadyPasted;

  @override
  void initState() {
    super.initState();
    _getAutoPasteValue();
    _alreadyPasted = false;
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    final Quote sendedQuote = ModalRoute.of(context).settings.arguments;

    if (sendedQuote != null) {
      _quote = sendedQuote;
      _quoteContentController.text = _quote.content;
    } else if (_autoPasteEnabled == true && _alreadyPasted == false) {
      _pasteFromClipboard();
      _alreadyPasted = true;
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
                      labelText: 'Quote',
                      hintText: AppLocalizations.of(context).translate('what_does_it_say'),
                      helperText: (_autoPasteEnabled == true) ? 'Auto paste enabled' : null,
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
                      _quote.content = text.trim();
                    },
                    onEditingComplete: () {
                      node.nextFocus();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    initialValue: _quote.author,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      hintText:
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
                  const SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    initialValue: _quote.source,
                    decoration: InputDecoration(
                      labelText: 'Source',
                      hintText:
                          '${AppLocalizations.of(context).translate('where_did_you_find_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      _quote.source = (text != '') ? text.trim() : null;
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
    if (_quote.id != null) {
      await AppDatabase.update('quotes', _quote.id, _quote.toMap());
    } else {
      var quoteId = await AppDatabase.insert('quotes', _quote.toMap());
      _quote.id = quoteId;
    }
    Navigator.pop(context, _quote);
  }

  void _pasteFromClipboard() {
    FlutterClipboard.paste().then((value) {
      _quote.content = value.trim();
      _quoteContentController.text = value;
    });
  }

  void _getAutoPasteValue() {
    SharedPreferences.getInstance().then((prefs) {
      _autoPasteEnabled = prefs.getBool('autoPaste');
    });
  }
}
