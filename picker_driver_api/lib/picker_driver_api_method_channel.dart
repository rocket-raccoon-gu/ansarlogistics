import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'picker_driver_api_platform_interface.dart';

/// An implementation of [PickerDriverApiPlatform] that uses method channels.
class MethodChannelPickerDriverApi extends PickerDriverApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('picker_driver_api');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
