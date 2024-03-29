import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stoic/db/quote_repository.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  final Quote quote;

  const AddQuote(this.quote);

  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _notesController = TextEditingController();
  late TextEditingController _authorController;
  late TextEditingController _sourceController;
  late FocusNode _authorFieldFocusNode;
  final bool _autoPasteEnabled = Hive.box('settings').get('autopaste', defaultValue: false) as bool;
  bool _isContentEmpty = true;
  late bool _isNotesEmpty;
  List<Quote> _quotes = [];

  @override
  void initState() {
    super.initState();
    _getQuotes();
    _runAutoPaste();
    _isNotesEmpty = widget.quote.notes?.isEmpty ?? true;
    _notesController
      ..addListener(_notesFieldListener)
      ..text = widget.quote.notes ?? '';
    _contentController
      ..addListener(_contentFieldListener)
      ..text = widget.quote.content;
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
            padding: const EdgeInsets.all(16),
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
                      border: const OutlineInputBorder(),
                      suffixIcon: (_isContentEmpty == true)
                          ? IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: _pasteContentFromClipboard,
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearContent,
                            ),
                    ),
                    validator: (text) {
                      if (text?.isEmpty == true) {
                        return AppLocalizations.of(context).translate('we_cannot_save_quote');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.trim().isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      final Iterable<String> authors = _quotes.map((e) => e.author ?? '').toSet();

                      return authors.where((author) {
                        return author.toLowerCase().contains(textEditingValue.text.trim().toLowerCase());
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _authorFieldFocusNode = focusNode;
                      _authorController = controller;
                      controller.text = widget.quote.author ?? '';

                      return TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('author'),
                          hintText:
                              '${AppLocalizations.of(context).translate('who_said_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                          border: const OutlineInputBorder(),
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
                        return const Iterable<String>.empty();
                      }

                      final Iterable<String> sources = _quotes.map((e) => e.source ?? '').toSet();

                      return sources.where((source) {
                        return source.toLowerCase().contains(textEditingValue.text.trim().toLowerCase());
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _sourceController = controller;
                      controller.text = widget.quote.source ?? '';

                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('source'),
                          hintText:
                              '${AppLocalizations.of(context).translate('where_did_you_find_it')} ${'(${AppLocalizations.of(context).translate('optional').toLowerCase()})'}',
                          border: const OutlineInputBorder(),
                        ),
                        onEditingComplete: () {
                          if (_isNotesEmpty) {
                            node.unfocus();
                            _addQuote();
                          } else {
                            node.nextFocus();
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_isNotesEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.note_add),
                        label: Text(AppLocalizations.of(context).translate('add_notes')),
                        onPressed: _addNotes,
                      ),
                    )
                  else
                    TextFormField(
                      minLines: 1,
                      maxLines: 2,
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).translate('notes'),
                        hintText: AppLocalizations.of(context).translate('notes_placeholder'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _clearNotes,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
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

  Future<void> _addQuote() async {
    if (_formKey.currentState!.validate()) {
      widget.quote.content = _contentController.text.trim();
      widget.quote.author = _authorController.text.trim().isNotEmpty ? _authorController.text.trim() : null;
      widget.quote.source = _sourceController.text.trim().isNotEmpty ? _sourceController.text.trim() : null;
      widget.quote.notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

      final quoteRepository = QuoteRepository();

      if (widget.quote.id != null) {
        await quoteRepository.update(widget.quote);
      } else {
        widget.quote.id = await quoteRepository.insert(widget.quote);
      }

      if (mounted) {
        Navigator.pop(context, widget.quote);
      }
    }
  }

  void _pasteContentFromClipboard() {
    FlutterClipboard.paste().then((value) {
      _contentController
        ..text = value
        ..selection = TextSelection.collapsed(offset: _contentController.text.length);
    });
  }

  void _runAutoPaste() {
    if (_autoPasteEnabled && widget.quote.content.isEmpty) {
      _pasteContentFromClipboard();
    }
  }

  Future<void> _getQuotes() async {
    final quoteRepository = QuoteRepository();
    final List<Quote> records = await quoteRepository.selectAll();
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

  void _addNotes() {
    setState(() {
      _isNotesEmpty = false;
    });
  }

  void _clearNotes() {
    setState(() {
      _notesController.text = '';
      _isNotesEmpty = true;
    });
  }

  void _notesFieldListener() {
    if (_notesController.text.endsWith('\n\n')) {
      _notesController.text = _notesController.text.trim();
      _addQuote();
    }
  }
}
