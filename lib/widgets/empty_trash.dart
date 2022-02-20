import 'package:flutter/material.dart';
import 'package:stoic/theme.dart';

class EmptyTrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: Text(
          'Nothing in trash ✨',
          style: myTheme.textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
