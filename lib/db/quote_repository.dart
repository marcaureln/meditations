import 'package:sembast/sembast.dart';
import 'package:stoic/db/app_database.dart';
import 'package:stoic/models/quote.dart';

class QuoteRepository {
  static const String quoteStoreName = 'quotes';

  final _quoteStore = intMapStoreFactory.store(quoteStoreName);

  Future<Database> get _db async => AppDatabase().database;

  Future<int> insert(Quote quote) async {
    return _quoteStore.add(await _db, quote.toMap());
  }

  Future delete(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _quoteStore.delete(await _db, finder: finder);
  }

  Future update(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    quote.updatedAt = DateTime.now();
    await _quoteStore.update(await _db, quote.toMap(), finder: finder);
  }

  Future<Quote> select(int id) async {
    final record = _quoteStore.record(id);
    final map = await record.get(await _db);
    return Quote.fromMap(id, map!);
  }

  Future<List<Quote>> selectAll() async {
    final snapshot = await _quoteStore.find(await _db);
    final List<Quote> records = [];

    for (final record in snapshot) {
      records.add(Quote.fromMap(record.key, record.value));
    }

    return records;
  }
}
