import 'package:flutter/material.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/theme/theme.dart';

class ChangeLanguageDialogContent extends StatefulWidget {
  final String currentLanguage;

  ChangeLanguageDialogContent(this.currentLanguage);

  _ChangeLanguageDialogContentState createState() =>
      _ChangeLanguageDialogContentState(currentLanguage);
}

class _ChangeLanguageDialogContentState
    extends State<ChangeLanguageDialogContent> {
  _ChangeLanguageDialogContentState(this.currentLanguage);
  final String currentLanguage;

  static const Map<String, String> _supportedLanguages = {
    'en': 'English',
    'fr': 'French'
  };

  String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = this.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var key in _supportedLanguages.keys)
          ListTile(
            title: Text(_supportedLanguages[key]),
            leading: Radio(
              value: key,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
          ),
        RaisedButton(
          child: Text('Save'),
          color: myTheme.accentColor,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
