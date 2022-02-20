import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stoic/db/quote_repository.dart';
import 'package:stoic/localization.dart';
import 'package:stoic/views/import.dart';
import 'package:stoic/views/trash.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _rootPath = Directory('/storage/emulated/0/');
  late bool _autoPasteEnabled;

  @override
  void initState() {
    super.initState();
    _autoPasteEnabled = Hive.box('settings').get('autopaste', defaultValue: false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('settings_appbar_title'))),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        children: [
          ListTile(
            leading: const SizedBox(
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
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.import_export),
            ),
            title: Text(
              '${AppLocalizations.of(context).translate('import')}/${AppLocalizations.of(context).translate('export')}',
            ),
            subtitle: Text(AppLocalizations.of(context).translate('settings_import_export_sub')),
            onTap: _showImportExportDialog,
          ),
          ListTile(
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.feedback),
            ),
            title: Text(AppLocalizations.of(context).translate('settings_feedback')),
            subtitle: Text(AppLocalizations.of(context).translate('settings_feedback_sub')),
            onTap: _sendFeedback,
          ),
          ListTile(
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.share),
            ),
            title: Text(AppLocalizations.of(context).translate('settings_share')),
            subtitle: Text(AppLocalizations.of(context).translate('settings_share_sub')),
            onTap: _share,
          ),
          ListTile(
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.recycling),
            ),
            title: Text(AppLocalizations.of(context).translate('trash')),
            subtitle: Text(AppLocalizations.of(context).translate('settings_trash_sub')),
            onTap: _showTrash,
          ),
          ListTile(
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.info),
            ),
            title: Text(AppLocalizations.of(context).translate('settings_about')),
            onTap: _showAboutPage,
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    _launchURL('mailto:alexmarcaureln@gmail.com');
  }

  void _share() {
    Share.share('https://github.com/marcaureln/stoic');
  }

  Future<void> _launchURL(String url) async {
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
        child: SizedBox(
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
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.download),
                    ),
                    Text(AppLocalizations.of(context).translate('export')),
                  ],
                ),
              ),
              const VerticalDivider(indent: 16, endIndent: 16),
              TextButton(
                onPressed: _import,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.upload),
                    ),
                    Text(AppLocalizations.of(context).translate('import')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export() async {
    final dir = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: _rootPath,
      fsType: FilesystemType.folder,
      pickText: 'Save file here',
      folderIconColor: Colors.black,
      requestPermission:
          !(Platform.isAndroid || Platform.isIOS) ? () async => Permission.storage.request().isGranted : null,
    );

    if (dir != null) {
      final file = File(path.join(dir, 'Meditations ${DateTime.now()}.json'));
      final quoteRepository = QuoteRepository();
      final quotes = await quoteRepository.selectAll();
      final records = quotes.map((e) => e.toMap()).toList();

      file.writeAsString(jsonEncode(records)).then((file) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).translate('save_as')} ${file.path}')));
      }).onError((FileSystemException error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      });

      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _import() async {
    final path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      rootDirectory: _rootPath,
      fsType: FilesystemType.file,
      folderIconColor: Colors.black,
      allowedExtensions: ['.json'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      requestPermission:
          !(Platform.isAndroid || Platform.isIOS) ? () async => Permission.storage.request().isGranted : null,
    );

    if (path != null) {
      final file = File(path);
      final jsonRaw = await file.readAsString();
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Import(raw: jsonRaw)));
      }
    }
  }

  Future<void> _showAboutPage() async {
    final String appVersion = await PackageInfo.fromPlatform().then(
      (packageInfo) => '${packageInfo.version} build ${packageInfo.buildNumber}',
      onError: (_) => AppLocalizations.of(context).translate('error_version'),
    );

    showLicensePage(
      context: context,
      applicationVersion: appVersion,
    );
  }

  Future<void> _setAutoPasteValue(bool value) async {
    final box = await Hive.openBox('settings');
    box.put('autopaste', value);
    setState(() {
      _autoPasteEnabled = value;
    });
  }

  void _showTrash() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Trash()));
  }
}
