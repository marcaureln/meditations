import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stoic/db/quote_dao.dart';
import 'package:stoic/theme/app_localizations.dart';
import 'package:stoic/views/import.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _rootPath = Directory('/storage/emulated/0/');
  String _currentVersion = '';
  bool _autoPasteEnabled = false;

  @override
  void initState() {
    super.initState();
    _getAutoPasteValue();
    _getCurrentVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('settings_appbar_title'))),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(8),
        children: [
          ListTile(
            leading: Container(
              height: double.infinity,
              child: Icon(Icons.paste),
            ),
            trailing: Switch(
              value: _autoPasteEnabled,
              onChanged: _setAutoPasteValue,
            ),
            title: Text(AppLocalizations.of(context).translate('settings_auto_paste')),
            subtitle: Text(AppLocalizations.of(context).translate('settings_auto_paste_sub')),
          ),
          ListTile(
            leading: Container(
              height: double.infinity,
              child: Icon(Icons.import_export),
            ),
            title: Text('Import/Export'),
            subtitle: Text('Save or import quotes'),
            onTap: _showImportExportDialog,
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
            onTap: () {
              showLicensePage(
                context: context,
                applicationVersion: _currentVersion,
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendFeedback() async {
    _launchURL("mailto:alexmarcaureln@gmail.com");
  }

  void _share() {
    Share.share("https://github.com/marcaureln/stoic");
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('error_launch_url')),
        ),
      );
    }
  }

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 150,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _export,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.download),
                    ),
                    Text('Export'),
                  ],
                ),
              ),
              VerticalDivider(indent: 16, endIndent: 16),
              TextButton(
                onPressed: _import,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.upload),
                    ),
                    Text('Import'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _export() async {
    final dir = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: _rootPath,
      fsType: FilesystemType.folder,
      pickText: 'Save file here',
      folderIconColor: Colors.black,
      requestPermission:
          !(Platform.isAndroid || Platform.isIOS) ? () async => await Permission.storage.request().isGranted : null,
    );

    if (dir != null) {
      final file = File(path.join(dir, 'Meditations ${DateTime.now()}.json'));
      final quoteDao = QuoteDAO();
      final quotes = await quoteDao.selectAll();
      final records = quotes.map((e) => e.toMap()).toList();
      file.writeAsString(jsonEncode(records)).then((file) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File save as ${file.path}')));
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      });
    }
  }

  void _import() async {
    final path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      rootDirectory: _rootPath,
      fsType: FilesystemType.file,
      folderIconColor: Colors.black,
      allowedExtensions: ['.json'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      requestPermission:
          !(Platform.isAndroid || Platform.isIOS) ? () async => await Permission.storage.request().isGranted : null,
    );

    if (path != null) {
      final file = File('$path');
      final jsonRaw = await file.readAsString();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Import(raw: jsonRaw)));
    }
  }

  void _getCurrentVersion() {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        _currentVersion = '${packageInfo.version} build ${packageInfo.buildNumber}';
      });
    }).catchError((_) {
      setState(() {
        _currentVersion = AppLocalizations.of(context).translate('error_version');
      });
    });
  }

  void _getAutoPasteValue() async {
    var box = await Hive.openBox('preferences');
    _autoPasteEnabled = box.get('autopaste', defaultValue: false);
  }

  void _setAutoPasteValue(value) async {
    var box = await Hive.openBox('preferences');
    await box.put('autopaste', value);
    setState(() {
      _autoPasteEnabled = value;
    });
  }
}
