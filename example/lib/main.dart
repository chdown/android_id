import 'dart:async';

import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _androidIdPlugin = AndroidId();

  var _androidId = 'Unknown';
  var _isEmulator = false;

  @override
  void initState() {
    super.initState();
    _initAndroidId();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initAndroidId() async {
    String androidId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      androidId = await _androidIdPlugin.getId() ?? 'Unknown ID';
    } on PlatformException {
      androidId = 'Failed to get Android ID.';
    }
    try {
      _isEmulator = await _androidIdPlugin.isEmulator() ?? true;
    } on PlatformException {
      androidId = 'Failed to get _isRealDevice.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _androidId = androidId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Android ID: $_androidId'),
              Text('_isRealDevice: ${_isEmulator ? "模拟设备" : "物理设备"}'),
            ],
          ),
        ),
      ),
    );
  }
}
