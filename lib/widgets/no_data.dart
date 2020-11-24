import 'package:flutter/material.dart';
import 'package:stoic/theme/text.dart';

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.height * .1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'No quotes found...',
              style: myTextTheme.bodyText1,
            ),
            Text(
              'Add your first quote 👇',
              style: myTextTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
