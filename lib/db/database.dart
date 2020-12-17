import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  static const String _dbName = 'database.db';

  Future<Database> get database async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, _dbName);
    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }

  static Future<int> insert(String storeName, Map map) async {
    final store = intMapStoreFactory.store(storeName);
    return await store.add(await AppDatabase.instance.database, map);
  }

  static Future delete(String storeName, int id) async {
    final store = intMapStoreFactory.store(storeName);
    final finder = Finder(filter: Filter.byKey(id));
    await store.delete(await AppDatabase.instance.database, finder: finder);
  }

  // TODO: implement update and select

  // TODO: return a list instead of record snapshot
  static Future getAllRecords(String storeName) async {
    final store = intMapStoreFactory.store(storeName);
    return await store.find(await AppDatabase.instance.database);
  }
}
