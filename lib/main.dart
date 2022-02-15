import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stoic/widgets/app.dart';

Future<void> main() async {
  await Hive.initFlutter();

  LicenseRegistry.addLicense(() async* {
    final ptSerifLicense = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], ptSerifLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final openSansLicense = await rootBundle.loadString('assets/google_fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], openSansLicense);
  });

  runApp(MyApp());
}
