import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static const String dbName = 'database.db';

  // ignore: prefer_constructors_over_static_methods
  static AppDatabase get instance => AppDatabase._();

  AppDatabase._();

  Future<Database> get database async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDocumentDir.path, dbName);
    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }
}
