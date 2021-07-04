import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:hive/hive.dart';
import 'package:stoic/db/quote_dao.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/models/quote.dart';

// ignore: must_be_immutable
class AddQuote extends StatefulWidget {
  Quote quote;

  AddQuote({this.quote});

  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  TextEditingController _authorController;
  TextEditingController _sourceController;
  FocusNode _authorFieldFocusNode;
  bool _autoPasteEnabled;
  bool _alreadyPasted;
  bool _isContentEmpty;

  List<Quote> _quotes;

  @override
  void initState() {
    super.initState();
    if (widget.quote == null) {
      widget.quote = Quote('');
    } else {
      _contentController.text = widget.quote.content;
    }
    _getQuotes();
    _runAutoPaste();
    _alreadyPasted = false;
    _isContentEmpty = true;
    _contentController.addListener(_contentFieldListener);
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);

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
                  ),
                  const SizedBox(height: 20),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.trim().isEmpty) {
                        return List<String>.empty();
                      }
                      return _quotes
                          ?.map((quote) => quote.author)
                          ?.where((author) =>
                              author != null &&
                              author.toLowerCase().contains(textEditingValue.text.trim().toLowerCase()))
                          ?.toSet()
                          ?.toList();
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _authorFieldFocusNode = focusNode;
                      _authorController = controller;
                      controller.text = widget.quote.author;

                      return TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('author'),
                          hintText:
                              '${AppLocalizations.of(context).translate('who_said_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                          border: OutlineInputBorder(),
                        ),
                        onEditingComplete: () {
                          node.nextFocus();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.trim().isEmpty) {
                        return List<String>.empty();
                      }
                      return _quotes
                          ?.map((quote) => quote.source)
                          ?.where((source) =>
                              source != null &&
                              source.toLowerCase().contains(textEditingValue.text.trim().toLowerCase()))
                          ?.toSet()
                          ?.toList();
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _sourceController = controller;
                      controller.text = widget.quote.source;

                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('source'),
                          hintText:
                              '${AppLocalizations.of(context).translate('where_did_you_find_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                          border: OutlineInputBorder(),
                        ),
                        onEditingComplete: () {
                          node.unfocus();
                          _addQuote();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text(AppLocalizations.of(context).translate('save')),
                      onPressed: _addQuote,
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
    if (_formKey.currentState.validate()) {
      widget.quote.content = _contentController.text.trim();
      widget.quote.author = _authorController.text.trim().isNotEmpty ? _authorController.text.trim() : null;
      widget.quote.source = _sourceController.text.trim().isNotEmpty ? _sourceController.text.trim() : null;

      final quoteDao = QuoteDAO();

      if (widget.quote.id != null) {
        await quoteDao.update(widget.quote);
      } else {
        widget.quote.id = await quoteDao.insert(widget.quote);
      }

      Navigator.pop(context, widget.quote);
    }
  }

  void _pasteContentFromClipboard() {
    FlutterClipboard.paste().then((value) {
      _contentController
        ..text = value
        ..selection = TextSelection.collapsed(offset: _contentController.text.length);
    });
  }

  void _runAutoPaste() async {
    var box = await Hive.openBox('preferences');
    _autoPasteEnabled = box.get('autopaste', defaultValue: false);
    if (_autoPasteEnabled && _alreadyPasted == false) {
      _pasteContentFromClipboard();
      _alreadyPasted = true;
    }
  }

  void _getQuotes() async {
    final quoteDao = QuoteDAO();
    List<Quote> records = await quoteDao.selectAll();
    _quotes = records;
  }

  void _clearContent() {
    _contentController.clear();
  }

  void _contentFieldListener() {
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
