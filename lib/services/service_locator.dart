import 'dart:async';

import 'package:ansarlogistics/navigations/navigation.dart';
import 'package:ansarlogistics/services/api_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:picker_driver_api/picker_driver_api.dart';

abstract class CubitsLocator {
  void resetCubits();
  void configCubits();
}

class ServiceLocator implements CubitsLocator {
  final GetIt _registry;
  String _baseUrl;
  final String _applicationPath;
  final bool _debuggable;

  ServiceLocator(
    this._baseUrl,
    this._applicationPath, {
    bool debuggable = kDebugMode,
  }) : _debuggable = debuggable,
       _registry = GetIt.asNewInstance();

  NavigationService get navigationService => _registry.get<NavigationService>();

  PDApiGateway get tradingApi => _registry.get<PDApiGateway>();

  void config() {
    _registry.registerLazySingleton(() => NavigationService());

    _registry.registerLazySingleton(
      () => PDApiGateway(
        _debuggable
            ? PickerDriverApi.debuggable(
              baseUrl: _baseUrl,
              applicationPath: _applicationPath,
              productUrl: 'https://www.ansargallery.com/en/rest/V1/',
            )
            : PickerDriverApi.create(
              baseUrl: _baseUrl,
              applicationPath: _applicationPath,
              productUrl: 'https://www.ansargallery.com/en/rest/V1/',
            ),
        StreamController<String>.broadcast(),
      ),
    );
  }

  @override
  void configCubits() {
    // TODO: implement configCubits
  }

  @override
  void resetCubits() {
    // TODO: implement resetCubits
  }

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;

    if (_registry.isRegistered<PDApiGateway>()) {
      _registry.unregister<PDApiGateway>();
    }

    _registry.registerLazySingleton(
      () => PDApiGateway(
        _debuggable
            ? PickerDriverApi.debuggable(
              baseUrl: _baseUrl,
              applicationPath: _applicationPath,
              productUrl: 'https://www.ansargallery.com/en/rest/V1/',
            )
            : PickerDriverApi.create(
              baseUrl: _baseUrl,
              applicationPath: _applicationPath,
              productUrl: 'https://www.ansargallery.com/en/rest/V1/',
            ),
        StreamController<String>.broadcast(),
      ),
    );
  }
}
