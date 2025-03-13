import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'picker_driver_api_method_channel.dart';

abstract class PickerDriverApiPlatform extends PlatformInterface {
  /// Constructs a PickerDriverApiPlatform.
  PickerDriverApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static PickerDriverApiPlatform _instance = MethodChannelPickerDriverApi();

  /// The default instance of [PickerDriverApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelPickerDriverApi].
  static PickerDriverApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PickerDriverApiPlatform] when
  /// they register themselves.
  static set instance(PickerDriverApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
