import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:stoic/widgets/app.dart';

void main() {
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
