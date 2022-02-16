import 'package:flutter/material.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/theme.dart';

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: Text(
          '${AppLocalizations.of(context).translate('no_data')} 👇',
          style: myTheme.textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
