import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_state.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:picker_driver_api/responses/driver_base_response.dart';

class OrderRoutesPageCubit extends Cubit<OrderRoutesPageState> {
  BuildContext context;
  Map<String, dynamic> mydata;
  OrderRoutesPageCubit(this.context, this.mydata)
    : super(OrderRoutePageLoadingState()) {
    loaddata();
  }

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> waypoints = [];
  List<String> stopLabels = [];

  String totalDistanceText = "";
  String totalDurationText = "";

  Future<void> loaddata() async {
    if (!isClosed) {
      emit(OrderRoutePageLoadingState());
    }

    waypoints.clear();
    stopLabels.clear();
    markers.clear();
    polylines.clear();

    final String? latval = await PreferenceUtils.getDataFromShared("userlat");
    final String? longval = await PreferenceUtils.getDataFromShared("userlong");

    final origin = LatLng(
      double.tryParse(latval ?? '') ?? ansarlocation.latitude,
      double.tryParse(longval ?? '') ?? ansarlocation.longitude,
    );
    waypoints.add(origin);
    stopLabels.add('My Location');

    final raw = mydata['data'];
    final List<DataItem> orders =
        raw is List
            ? raw.whereType<DataItem>().toList()
            : const <DataItem>[];

    for (final order in orders) {
      final lat = double.tryParse(order.address.latitude.toString());
      final lng = double.tryParse(order.address.longitude.toString());
      if (lat == null || lng == null) continue;
      if (lat == 0 && lng == 0) continue;

      waypoints.add(LatLng(lat, lng));
      stopLabels.add(
        order.order.subgroupIdentifier.isNotEmpty
            ? order.order.subgroupIdentifier
            : (order.customer.name.isNotEmpty
                ? order.customer.name
                : 'Stop ${waypoints.length}'),
      );
    }

    if (waypoints.length < 2) {
      if (!isClosed) emit(OrderRoutesPageEmptyState());
      return;
    }

    await _getRouteWithWaypoints();
  }

  Future<void> _getRouteWithWaypoints() async {
    try {
      final origin = waypoints.first;
      final destination = waypoints.last;
      final intermediates =
          waypoints.length > 2
              ? waypoints.sublist(1, waypoints.length - 1)
              : const <LatLng>[];

      var url =
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origin.latitude},${origin.longitude}&"
          "destination=${destination.latitude},${destination.longitude}&"
          "key=$google_api_key";

      if (intermediates.isNotEmpty) {
        final waypointsParam = intermediates
            .map((point) => "${point.latitude},${point.longitude}")
            .join('|');
        url += "&waypoints=optimize:true|$waypointsParam";
      }

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK' &&
          data['routes'] is List &&
          (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final legs = route['legs'] as List<dynamic>;

        int totalDistance = 0;
        int totalDuration = 0;
        for (final leg in legs) {
          totalDistance += (leg['distance']?['value'] as num? ?? 0).toInt();
          totalDuration += (leg['duration']?['value'] as num? ?? 0).toInt();
        }

        totalDistanceText = '${(totalDistance / 1000).toStringAsFixed(2)} km';
        totalDurationText = _formatDuration(Duration(seconds: totalDuration));

        final points = route['overview_polyline']?['points']?.toString() ?? '';
        final routeCoordinates = _decodePolyline(points);

        final waypointOrder =
            (route['waypoint_order'] as List<dynamic>?) ?? const [];
        await _addOptimizedMarkers(waypoints, waypointOrder);

        polylines.add(
          Polyline(
            polylineId: const PolylineId('multiRoute'),
            points:
                routeCoordinates.isNotEmpty ? routeCoordinates : waypoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      } else {
        totalDistanceText = '-';
        totalDurationText = '-';
        await _addSequentialMarkers();
      }

      if (!isClosed) {
        emit(
          OrderRoutesPageInitialState(
            markers: markers,
            polylines: polylines,
            totalDistanceText: totalDistanceText,
            totalDurationText: totalDurationText,
          ),
        );
      }

      if (mapController != null) {
        final bounds = _getBounds(waypoints);
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
      }
    } catch (e) {
      await _addSequentialMarkers();
      if (!isClosed) {
        emit(
          OrderRoutesPageInitialState(
            markers: markers,
            polylines: polylines,
            totalDistanceText: '-',
            totalDurationText: '-',
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours > 0 ? '$hours hr ' : ''}$minutes min';
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  Future<void> _addOptimizedMarkers(
    List<LatLng> points,
    List<dynamic> order,
  ) async {
    markers.clear();

    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: points.first,
        infoWindow: InfoWindow(title: stopLabels.first),
        icon: await _createNumberMarker(1, Colors.blue),
      ),
    );

    if (order.isEmpty) {
      await _addSequentialMarkers(includeOrigin: false);
      return;
    }

    for (int i = 0; i < order.length; i++) {
      final pointIndex = (order[i] as num).toInt() + 1;
      if (pointIndex < 0 || pointIndex >= points.length) continue;
      markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: points[pointIndex],
          infoWindow: InfoWindow(
            title: stopLabels.length > pointIndex
                ? stopLabels[pointIndex]
                : 'Stop ${i + 2}',
          ),
          icon: await _createNumberMarker(i + 2, Colors.green),
        ),
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: points.last,
        infoWindow: InfoWindow(
          title: stopLabels.last,
        ),
        icon: await _createNumberMarker(points.length, Colors.red),
      ),
    );
  }

  Future<void> _addSequentialMarkers({bool includeOrigin = true}) async {
    if (includeOrigin) markers.clear();

    final startIndex = includeOrigin ? 0 : 1;
    for (int i = startIndex; i < waypoints.length; i++) {
      final color =
          i == 0
              ? Colors.blue
              : (i == waypoints.length - 1 ? Colors.red : Colors.green);
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: waypoints[i],
          infoWindow: InfoWindow(
            title: i < stopLabels.length ? stopLabels[i] : 'Stop ${i + 1}',
          ),
          icon: await _createNumberMarker(i + 1, color),
        ),
      );
    }
  }

  Future<BitmapDescriptor> _createNumberMarker(int number, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    const double size = 50.0;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number.toString(),
      style: const TextStyle(
        fontSize: 20.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - textPainter.height / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    if (minLat == maxLat && minLng == maxLng) {
      return LatLngBounds(
        southwest: LatLng(minLat - 0.01, minLng - 0.01),
        northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (waypoints.length >= 2) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(waypoints), 60),
      );
    }
  }
}
