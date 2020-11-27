import 'package:flutter/material.dart';

import 'package:stoic/db/quotes_dao.dart';
import 'package:stoic/theme/theme.dart';
import 'package:stoic/models/quote.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  Quote _quote;

  initState() {
    super.initState();
    _quote = Quote('');
  }

  @override
  Widget build(BuildContext context) {
    QuotesDao dao = QuotesDao();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a quote'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * .5,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                    // autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'What does it say',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.content = text;
                    }),
                TextField(
                    decoration: InputDecoration(
                      labelText: 'Who said it (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.author = (text != '') ? text : null;
                    }),
                TextField(
                    decoration: InputDecoration(
                      labelText: 'Where did you find it (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String text) {
                      _quote.source = (text != '') ? text : null;
                    }),
                Container(
                  child: RaisedButton(
                    elevation: 6,
                    color: myTheme.accentColor,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (_quote.content == '' || _quote.content == null) {
                        //TODO: show snackbar or an alert dialog
                      }
                      dao.insertQuote(_quote);
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
