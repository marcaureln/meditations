import 'package:sembast/sembast.dart';
import 'package:stoic/db/app_database.dart';
import 'package:stoic/models/quote.dart';

class QuoteDAO {
  static const String quoteStoreName = 'quotes';

  final _quoteStore = intMapStoreFactory.store(quoteStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insert(Quote quote) async {
    return await _quoteStore.add(await _db, quote.toMap());
  }

  Future delete(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _quoteStore.delete(await _db, finder: finder);
  }

  Future update(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _quoteStore.update(await _db, quote.toMap(), finder: finder);
  }

  Future<Quote> select(int id) async {
    final record = _quoteStore.record(id);
    final map = await record.get(await _db);
    return Quote.fromMap(id, map);
  }

  Future<List<Quote>> selectAll() async {
    final snapshot = await _quoteStore.find(await _db);
    List<Quote> records = [];

    for (var record in snapshot) {
      records.add(Quote.fromMap(record.key, record.value));
    }

    return records;
  }
}
