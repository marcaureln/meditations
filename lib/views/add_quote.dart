import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:hive/hive.dart';
import 'package:stoic/db/quote_dao.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authorFieldFocusNode = FocusNode();
  Quote _quote = Quote('');
  bool _autoPasteEnabled;
  bool _alreadyPasted;
  bool _isContentEmpty;

  @override
  void initState() {
    super.initState();
    _getAutoPasteValue();
    _alreadyPasted = false;
    _isContentEmpty = true;
    _contentController.addListener(_contentListener);
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    final Quote sendedQuote = ModalRoute.of(context).settings.arguments;

    if (_alreadyPasted == false && (sendedQuote != null || _autoPasteEnabled != null)) {
      if (sendedQuote != null) {
        _quote = sendedQuote;
        _contentController.text = _quote.content;
      }
      if (_autoPasteEnabled == true) {
        _pasteContentFromClipboard();
      }
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
                    controller: _contentController,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('quote'),
                      hintText: AppLocalizations.of(context).translate('what_does_it_say'),
                      helperText: (_autoPasteEnabled == true)
                          ? AppLocalizations.of(context).translate('auto_paste_enabled')
                          : null,
                      border: OutlineInputBorder(),
                      suffixIcon: (_isContentEmpty == true)
                          ? IconButton(
                              icon: Icon(Icons.paste),
                              onPressed: _pasteContentFromClipboard,
                            )
                          : IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _clearContent,
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
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    initialValue: _quote.author,
                    focusNode: _authorFieldFocusNode,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('author'),
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
                      labelText: AppLocalizations.of(context).translate('source'),
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
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
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
    final quoteDao = QuoteDAO();
    if (_quote.id != null) {
      await quoteDao.update(_quote);
    } else {
      _quote.id = await quoteDao.insert(_quote);
    }
    Navigator.pop(context, _quote);
  }

  void _pasteContentFromClipboard() {
    FlutterClipboard.paste().then((value) {
      _quote.content = value.trim();
      _contentController
        ..text = value
        ..selection = TextSelection.collapsed(offset: _contentController.text.length);
    });
  }

  void _getAutoPasteValue() async {
    var box = await Hive.openBox('preferences');
    _autoPasteEnabled = box.get('autopaste', defaultValue: false);
  }

  void _clearContent() {
    _contentController.clear();
    _quote.content = '';
  }

  void _contentListener() {
    if (_contentController.text.endsWith('\n\n')) {
      _authorFieldFocusNode.requestFocus();
      _contentController.text = _contentController.text.trim();
    }
    if (_contentController.text.isEmpty) {
      setState(() {
        _isContentEmpty = true;
      });
    } else if (_isContentEmpty == true) {
      setState(() {
        _isContentEmpty = false;
      });
    }
  }
}
