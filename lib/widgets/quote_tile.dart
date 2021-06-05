import 'package:flutter/material.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/theme/app_localizations.dart';

class QuoteTile extends InkWell {
  final Quote quote;

  QuoteTile({@required BuildContext context, @required this.quote, void Function() onTap, void Function() onLongPress})
      : super(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    '"${quote.content}"',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    (quote.author != null) ? quote.author : AppLocalizations.of(context).translate('anonymous'),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                if (quote.source != null)
                  Container(
                    width: double.infinity,
                    child: Text(quote.source),
                  ),
              ],
            ),
          ),
        );
}
