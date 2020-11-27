import 'dart:async';

import 'package:sembast/sembast.dart';

import 'package:stoic/db/database.dart';
import 'package:stoic/models/quote.dart';

class QuotesDao {
  static const String _storeName = "quotes";
  final _store = intMapStoreFactory.store(_storeName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insertQuote(Quote quote) async {
    return await _store.add(await _db, quote.toMap());
  }

  Future updateQuote(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _store.update(await _db, quote.toMap(), finder: finder);
  }

  Future deleteQuote(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _store.delete(await _db, finder: finder);
  }

  Future<List<Quote>> getAllQuotes() async {
    final recordSnapshot = await _store.find(await _db);
    return recordSnapshot.map((snapshot) {
      final quote = Quote.fromMap(snapshot.key, snapshot.value);
      return quote;
    }).toList();
  }
}
