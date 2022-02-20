import 'package:flutter/material.dart';
import 'package:stoic/db/quote_repository.dart';
import 'package:stoic/db/trash_repository.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/empty_trash.dart';
import 'package:stoic/widgets/quote_tile.dart';

class Trash extends StatefulWidget {
  const Trash({Key? key}) : super(key: key);

  @override
  _TrashState createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  final _trashRepository = TrashRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('trash')),
      ),
      body: FutureBuilder(
        future: _getQuotes(),
        builder: (context, AsyncSnapshot<List<Quote>> snapshot) {
          if (snapshot.hasData) {
            final List<Quote> quotes = snapshot.data!;

            if (quotes.isEmpty) {
              return EmptyTrash();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: quotes.length + 2,
              itemBuilder: (context, index) {
                if (index == quotes.length) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: Text(AppLocalizations.of(context).translate('empty_trash')),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: _emptyTrash,
                    ),
                  );
                }

                if (index == quotes.length + 1) {
                  //TODO: Remove quotes that last more than 30 days in trash
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Quotes in here the last 30 days will be deleted forever.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final Quote quote = quotes[index];
                return QuoteTile(
                  context: context,
                  quote: quote,
                  onTap: () {
                    _showOptions(quote);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return index < quotes.length - 1 ? const Divider(height: 12) : const SizedBox(height: 8);
              },
            );
          }

          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
        },
      ),
    );
  }

  Future<List<Quote>> _getQuotes() async {
    return _trashRepository.selectAll();
  }

  void _showOptions(Quote quote) {
    showModalBottomSheet(
      elevation: 8.0,
      context: context,
      builder: (context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuoteTile(context: context, quote: quote),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore_from_trash),
            title: Text(AppLocalizations.of(context).translate('restore')),
            onTap: () {
              _restoreQuote(quote);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(AppLocalizations.of(context).translate('delete_forever')),
            onTap: () {
              _removeForeverQuote(quote);
            },
          ),
          Container(height: 16.0),
        ],
      ),
    );
  }

  void _restoreQuote(Quote quote) {
    _trashRepository.delete(quote);
    QuoteRepository().insert(quote);
    Navigator.pop(context);
    setState(() {});
  }

  void _removeForeverQuote(Quote quote) {
    _trashRepository.delete(quote);
    Navigator.pop(context);
    setState(() {});
  }

  void _emptyTrash() {
    _trashRepository.empty();
    Navigator.pop(context);
  }
}
