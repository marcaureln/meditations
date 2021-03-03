import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stoic/theme/app_localizations.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentVersion = 'fetching...';
  bool _autoPasteEnabled;

  @override
  void initState() {
    super.initState();
    _getAutoPasteValue();
    _getCurrentVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('settings_appbar_title'))),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.paste),
                ),
                trailing: Container(
                  height: double.infinity,
                  child: Switch(
                    value: _autoPasteEnabled,
                    onChanged: (value) {
                      SharedPreferences.getInstance().then((instance) {
                        instance.setBool('autoPaste', _autoPasteEnabled);
                      });
                      setState(() {
                        _autoPasteEnabled = value;
                      });
                    },
                  ),
                ),
                title: Text('Activate Auto Paste'),
                subtitle: Text('Automatically paste content of quote'),
              ),
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.feedback),
                ),
                title: Text(AppLocalizations.of(context).translate('settings_feedback')),
                subtitle: Text(AppLocalizations.of(context).translate('settings_feedback_sub')),
                onTap: _sendFeedback,
              ),
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.share),
                ),
                title: Text(AppLocalizations.of(context).translate('settings_share')),
                subtitle: Text(AppLocalizations.of(context).translate('settings_share_sub')),
                onTap: _share,
              ),
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.info),
                ),
                title: Text(AppLocalizations.of(context).translate('settings_about')),
                subtitle: Text('${AppLocalizations.of(context).translate('version')}: $_currentVersion'),
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
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Cannot launch $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  _getCurrentVersion() async {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        _currentVersion = '${packageInfo.version} build ${packageInfo.buildNumber}';
      });
    }).catchError(() {
      setState(() {
        _currentVersion = 'unable to find app version';
      });
    });
  }

  _getAutoPasteValue() async {
    var prefs = await SharedPreferences.getInstance();
    _autoPasteEnabled = prefs.getBool('autoPaste') ?? false;
  }
}
