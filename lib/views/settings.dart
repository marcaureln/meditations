import 'package:flutter/material.dart';
import 'package:stoic/widgets/appbar.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:stoic/theme/app_localizations.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static const String _currentVersion = 'in development';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(AppLocalizations.of(context).translate('settings_appbar_title')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              // Feedback
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.feedback),
                    ),
                    title: Text(AppLocalizations.of(context).translate('settings_feedback')),
                    subtitle: Text(AppLocalizations.of(context).translate('settings_feedback_sub')),
                    onTap: _sendFeedback,
                  ),
                ),
              ),
              // Share
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.share),
                    ),
                    title: Text(AppLocalizations.of(context).translate('settings_share')),
                    subtitle: Text(AppLocalizations.of(context).translate('settings_share_sub')),
                    onTap: _share,
                  ),
                ),
              ),
              // About
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.info),
                    ),
                    title: Text(AppLocalizations.of(context).translate('settings_about')),
                    subtitle: Text('${AppLocalizations.of(context).translate('version')}: $_currentVersion'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendFeedback() async {
    _launchURL("mailto:alexmarcaureln@gmail.com");
  }

  void _share() {
    _launchURL("https://github.com/marcaureln");
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
