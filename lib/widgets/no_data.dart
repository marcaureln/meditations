import 'package:flutter/material.dart';
import 'package:stoic/theme/theme.dart';

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        child: Text(
          'No quotes found... Add your first quote 👇',
          style: myTheme.textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
