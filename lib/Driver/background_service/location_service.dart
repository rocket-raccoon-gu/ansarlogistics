import 'dart:async';
import 'dart:developer';
import 'package:ansarlogistics/main.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  final StreamController<Position> _positionStreamController =
      StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionStreamController.stream;

  LocationService() {
    _init();
  }

  void _init() async {
    // Check for location permission
    if (await Permission.location.isGranted) {
      _startLocationUpdates();
    } else {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        _startLocationUpdates();
      } else {
        _positionStreamController.addError('Location permission denied');
      }
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) async {
        _positionStreamController.add(position);

        try {
          // Fetch the userId from shared preferences
          String? val = await PreferenceUtils.getDataFromShared('userid');

          // Update global variables
          UserController.userController.locationlatitude =
              position.latitude.toString();
          UserController.userController.locationlongitude =
              position.longitude.toString();

          // Update driver location via API
          final locator = ServiceLocator(
            UserController.userController.base,
            UserController.userController.producturl,

            // UserController.userController.applicationpath,
            debuggable: loggable,
          )..config();

          final resp = await locator.tradingApi.updateDriverLocationdetails(
            userId: int.parse(val ?? "0"),
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString(),
          );

          if (resp.statusCode == 200) {
            PreferenceUtils.storeDataToShared(
              "driverlat",
              position.latitude.toString(),
            );
            PreferenceUtils.storeDataToShared(
              "driverlong",
              position.longitude.toString(),
            );
            // log("Location updated: ${position.latitude}, ${position.longitude}");
          } else {
            log("Failed to update location");
          }
        } catch (e) {
          log("Error while updating location: $e");
        }
      },
      onError: (e) {
        log("Location stream error: $e");
        _positionStreamController.addError(e);
      },
    );
  }

  void dispose() {
    _positionStreamController.close();
  }
}
