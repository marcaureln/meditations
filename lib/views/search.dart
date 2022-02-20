import 'package:flutter/material.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/widgets/quote_tile.dart';

class QuoteSearchDelegate extends SearchDelegate<Quote> {
  final List<Quote> quotes;
  final BuildContext parentContext;

  QuoteSearchDelegate(this.quotes, this.parentContext)
      : super(
          searchFieldLabel: AppLocalizations.of(parentContext).translate('search'),
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, Quote(''));
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Quote> searchResults = _search(query, quotes);

    return ListView.separated(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 128),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final Quote quote = searchResults[index];
        return QuoteTile(
          context: context,
          quote: quote,
          onTap: () {
            close(context, quote);
          },
        );
      },
      separatorBuilder: (context, _) => const Divider(height: 12),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Quote> searchResults = _search(query, quotes);

    return ListView.separated(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 128),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final Quote quote = searchResults[index];
        return QuoteTile(
          context: context,
          quote: quote,
          onTap: () {
            close(context, quote);
          },
        );
      },
      separatorBuilder: (context, _) => const Divider(height: 12),
    );
  }

  List<Quote> _search(String terms, List<Quote> list) {
    return list
        .where(
          (quote) =>
              quote.content.toLowerCase().contains(terms) ||
              (quote.author?.toLowerCase().contains(terms) ?? false) ||
              (quote.source?.toLowerCase().contains(terms) ?? false),
        )
        .toList();
  }
}
