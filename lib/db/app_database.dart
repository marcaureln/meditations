import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static const String dbName = 'database.db';

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDocumentDir.path, dbName);
    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }
}
