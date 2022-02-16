import 'package:flutter/material.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/models/quote.dart';
import 'package:stoic/theme.dart';

class QuoteTile extends InkWell {
  final Quote quote;

  QuoteTile({required BuildContext context, required this.quote, void Function()? onTap, void Function()? onLongPress})
      : super(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '"${quote.content}"',
                    style: ptSerif.bodyText1,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    quote.author ?? AppLocalizations.of(context).translate('anonymous'),
                    style: ptSerif.bodyText2,
                  ),
                ),
                if (quote.source != null)
                  SizedBox(
                    width: double.infinity,
                    child: Text(quote.source ?? ''),
                  ),
              ],
            ),
          ),
        );
}
