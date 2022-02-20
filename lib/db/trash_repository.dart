import 'package:sembast/sembast.dart';
import 'package:stoic/db/app_database.dart';
import 'package:stoic/models/quote.dart';

class TrashRepository {
  static const String quoteStoreName = 'trash';

  final _trashStore = intMapStoreFactory.store(quoteStoreName);

  Future<Database> get _db async => AppDatabase().database;

  Future<int> insert(Quote quote) async {
    return _trashStore.add(await _db, quote.toMap());
  }

  Future delete(Quote quote) async {
    final finder = Finder(filter: Filter.byKey(quote.id));
    await _trashStore.delete(await _db, finder: finder);
  }

  Future<void> empty() async {
    _trashStore.drop(await _db);
  }

  Future<Quote> select(int id) async {
    final record = _trashStore.record(id);
    final map = await record.get(await _db);
    return Quote.fromMap(id, map!);
  }

  Future<List<Quote>> selectAll() async {
    final snapshot = await _trashStore.find(await _db);
    final List<Quote> records = [];

    for (final record in snapshot) {
      records.add(Quote.fromMap(record.key, record.value));
    }

    return records;
  }
}
