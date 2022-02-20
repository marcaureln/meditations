import 'package:sembast/sembast.dart';
import 'package:stoic/db/quote_repository.dart';
import 'package:stoic/models/quote.dart';

Future<void> migrate(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    final _quoteStore = intMapStoreFactory.store(QuoteRepository.quoteStoreName);
    final snapshot = await _quoteStore.find(db);
    final List<Quote> records = [];

    for (final record in snapshot) {
      records.add(Quote.fromMap(record.key, record.value));
    }

    for (final record in records) {
      final finder = Finder(filter: Filter.byKey(record.id));
      await _quoteStore.update(db, record.toMap(), finder: finder);
    }
  }
}
