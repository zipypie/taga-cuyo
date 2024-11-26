import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

Future<Map<String, String>> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = 'Unknown';
  String osVersion = 'Unknown';

  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      osVersion = androidInfo.version.release;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
    }
  } catch (e) {
    Logger.log("Error fetching device info: $e");
  }

  return {
    'deviceModel': deviceModel,
    'osVersion': osVersion,
  };
}
