import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    TextTheme _textTheme = Theme.of(context).textTheme;
    double _deviceHeight = MediaQuery.of(context).size.height;
    double _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _theme.scaffoldBackgroundColor,
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
                    title: Text('About'),
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
    // TODO: display simple dialog
  }

  void _sendFeedback() async {
    // TODO: send mail
  }

  void _share() {
    // TODO: share link
  }

  void _about() {
    // TODO: display simple dialog
  }
}
