import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static const String dbName = 'database.db';

  static AppDatabase get instance => AppDatabase._();

  AppDatabase._();

  Future<Database> get database async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, dbName);
    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }
}
