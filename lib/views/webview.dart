import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  @override
  MyWebViewState createState() => MyWebViewState();
}

class MyWebViewState extends State<MyWebView> {
  final defaultUrl = 'https://flutter.dev';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: (url != null) ? url : defaultUrl,
      ),
    );
  }
}
