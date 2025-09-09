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
  var _deviceInfo = <String, dynamic>{};
  var _existingFiles = <String>[];
  var _customFiles = <String>[];

  final _textController = TextEditingController();
  final _focusNode = FocusNode();

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

    // 获取设备信息
    try {
      _deviceInfo = await _androidIdPlugin.getDeviceInfo() ?? {};
    } on PlatformException {
      _deviceInfo = {'error': 'Failed to get device info'};
    }

    // 检查模拟器相关文件
    try {
      final emulatorFiles = [
        '/dev/socket/qemud',
        '/dev/qemu_pipe',
        '/system/lib/libc_malloc_debug_qemu.so',
        '/system/bin/microvirt-prop',
        '/system/bin/microvirt-uiautomator',
        '/system/bin/microvirtd',
        '/system/xbin/microvirt-prop',
        '/system/lib/libmumu.so',
        '/system/bin/mumu',
        '/system/xbin/mumu',
        '/data/data/com.netease.mumu',
        '/system/app/MuMuPlayer',
        '/system/lib/libwindroye.so',
        '/system/bin/windroye',
        '/system/xbin/windroye',
        '/data/data/com.windroye.xiaoyao',
        '/system/app/XiaoYao',
        '/system/lib/libnoxd.so',
        '/system/bin/noxd',
        '/system/xbin/noxd',
        '/data/data/com.nox.app',
        '/system/app/NoxPlayer',
        '/etc/mumu-configs',
      ];
      _existingFiles = await _androidIdPlugin.checkFilesExist(emulatorFiles) ?? [];
    } on PlatformException {
      _existingFiles = [];
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _androidId = androidId);
  }

  // 自定义文件检查方法
  Future<void> _checkCustomFiles() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入文件路径')),
        );
      }
      return;
    }

    // 支持多行输入，按换行符分割
    final filePaths = input.split('\n').where((path) => path.trim().isNotEmpty).toList();

    try {
      _customFiles = await _androidIdPlugin.checkFilesExist(filePaths) ?? [];
      if (mounted) {
        setState(() {});
      }

      if (mounted) {
        if (_customFiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未检测到任何文件')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('检测到 ${_customFiles.length} 个文件')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('检查文件时出错: ${e.message}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Android ID Plugin Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Android ID: $_androidId', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('设备类型: ${_isEmulator ? "模拟设备" : "物理设备"}', style: TextStyle(fontSize: 16, color: _isEmulator ? Colors.red : Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('设备信息:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._deviceInfo.entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text('${entry.key}: ${entry.value}'),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('检测到的模拟器文件 (${_existingFiles.length}个):', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_existingFiles.isEmpty)
                        const Text('未检测到模拟器相关文件', style: TextStyle(color: Colors.green))
                      else
                        ..._existingFiles
                            .map((file) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(file, style: const TextStyle(color: Colors.red)),
                                ))
                            .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('自定义文件检测:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '请输入文件路径，每行一个路径\n例如:\n/system/lib/libmumu.so\n/data/data/com.netease.mumu',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _checkCustomFiles,
                              icon: const Icon(Icons.search),
                              label: const Text('检测文件'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              _textController.clear();
                              _customFiles.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('清空'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      if (_customFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('检测结果 (${_customFiles.length}个文件存在):', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._customFiles
                            .map((file) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(file, style: const TextStyle(color: Colors.blue)),
                                ))
                            .toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
