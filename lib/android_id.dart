import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The plugin class for retrieving the Android ID.
class AndroidId {
  const AndroidId();

  /// The method channel used to interact with the native platform.
  static const _methodChannel = MethodChannel('android_id');

  /// Calls the native method to retrieve the Android ID.
  Future<String?> getId() async {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return null;

    return _methodChannel.invokeMethod<String?>('getId');
  }

  /// Calls the native method to retrieve the Android ID.
  Future<bool?> isEmulator() async {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return null;

    return _methodChannel.invokeMethod<bool?>('isEmulator');
  }

  /// 获取设备常用信息
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return null;

    final result = await _methodChannel.invokeMethod<Map<Object?, Object?>?>('getDeviceInfo');
    if (result == null) return null;

    return Map<String, dynamic>.from(result);
  }

  /// 检查文件数组中是否存在文件
  Future<List<String>?> checkFilesExist(List<String> filePaths) async {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return null;

    final result = await _methodChannel.invokeMethod<List<Object?>?>('checkFilesExist', {
      'filePaths': filePaths,
    });
    if (result == null) return null;

    return result.cast<String>();
  }
}
