import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:stoic/theme/theme.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: myTheme.scaffoldBackgroundColor,
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              // Language
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.translate),
                    ),
                    title: Text('Language'),
                    subtitle: Text('Change application language'),
                    onTap: _changeLanguage,
                  ),
                ),
              ),
              // Feedback
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.feedback),
                    ),
                    title: Text('Send feedback'),
                    subtitle: Text('Report a bug or request a feature'),
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
                    title: Text('Share'),
                    subtitle: Text('Share with friends and family'),
                    onTap: _share,
                  ),
                ),
              ),
              // About
              Container(
                child: Center(
                  child: ListTile(
                    leading: Container(child: Icon(Icons.info)),
                    title: Text('About us'),
                    onTap: _about,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguage() {
    String _language = 'English';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: [
              ListTile(
                title: Text('English'),
                leading: Radio(
                  value: 'English',
                  groupValue: _language,
                  onChanged: null,
                ),
              ),
            ],
          );
        });
  }

  void _sendFeedback() async {
    _launchURL("mailto:alexmarcaureln@gmail.com");
  }

  void _share() {
    // TODO: url of the launch page
    _launchURL("https://github.com/marcaureln");
  }

  void _about() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            ListTile(
              leading: Container(
                height: double.infinity,
                child: Icon(Icons.info),
              ),
              title: Text('Version'),
              subtitle: Text('beta'),
            )
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
