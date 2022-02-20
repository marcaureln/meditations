import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:stoic/db/migrations.dart';

class AppDatabase {
  static const String dbName = 'database.db';
  static const int dbVersion = 2;

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDocumentDir.path, dbName);
    final database = await databaseFactoryIo.openDatabase(dbPath, version: dbVersion, onVersionChanged: migrate);
    return database;
  }
}
