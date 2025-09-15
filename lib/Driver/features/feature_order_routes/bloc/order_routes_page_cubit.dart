import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_state.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:http/http.dart' as http;

class OrderRoutesPageCubit extends Cubit<OrderRoutesPageState> {
  BuildContext context;
  Map<String, dynamic> mydata;
  OrderRoutesPageCubit(this.context, this.mydata)
    : super(OrderRoutePageLoadingState()) {
    loaddata();
  }

  List<Order>? orderitems = [];

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> waypoints = [];

  String totalDistanceText = "";

  String totalDurationText = "";

  loaddata() async {
    String? latval = await PreferenceUtils.getDataFromShared("userlat");

    String? longval = await PreferenceUtils.getDataFromShared("userlong");

    if (!isClosed) {
      emit(OrderRoutePageLoadingState());
    }

    waypoints.add(
      LatLng(
        double.parse(latval ?? ansarlocation.latitude.toString()),
        double.parse(longval ?? ansarlocation.longitude.toString()),
      ),
    );

    if (mydata.containsKey('data') && mydata['data'].isNotEmpty) {
      orderitems = mydata['data'];

      orderitems!.forEach((ord) {
        waypoints.add(
          LatLng(double.parse(ord.latitude), double.parse(ord.longitude)),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getRouteWithWaypoints();
      });
    } else {
      emit(OrderRoutesPageEmptyState());
    }
  }

  Future<void> _getRouteWithWaypoints() async {
    final apiKey = google_api_key;
    final origin = waypoints.first;
    final destination = waypoints.last;
    final intermediates = waypoints.sublist(1, waypoints.length - 1);

    final waypointsParam = intermediates
        .map((point) => "${point.latitude},${point.longitude}")
        .join('|');

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${origin.latitude},${origin.longitude}&"
      "destination=${destination.latitude},${destination.longitude}&"
      "waypoints=optimize:true|$waypointsParam&"
      "key=$apiKey",
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    // Extract legs
    final legs = data['routes'][0]['legs'] as List<dynamic>;

    // Extract and accumulate total distance and duration
    int totalDistance = 0;
    int totalDuration = 0;
    List<String> legSummaries = [];

    for (int i = 0; i < legs.length; i++) {
      final leg = legs[i];
      final distance = leg['distance']['text'];
      final duration = leg['duration']['text'];
      totalDistance += (leg['distance']['value'] as num).toInt();
      totalDuration += (leg['duration']['value'] as num).toInt();

      legSummaries.add("Stop ${i + 1} to Stop ${i + 2}: $distance, $duration");
    }

    // Convert total to readable format
    totalDistanceText = '${(totalDistance / 1000).toStringAsFixed(2)} km';
    totalDurationText = _formatDuration(Duration(seconds: totalDuration));

    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      final routeCoordinates = await _decodePolyline(points);

      // Get optimized waypoint order
      final waypointOrder =
          data['routes'][0]['waypoint_order'] as List<dynamic>;

      // Add markers with numbers showing optimized order
      await _addOptimizedMarkers(waypoints, waypointOrder);

      // setState(() {
      polylines.add(
        Polyline(
          polylineId: PolylineId('multiRoute'),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
      // isLoading = false;
      // });

      emit(
        OrderRoutesPageInitialState(
          markers: markers,
          polylines: polylines,
          totalDistanceText: totalDistanceText,
          totalDurationText: totalDurationText,
        ),
      );

      if (mapController != null) {
        final bounds = _getBounds(waypoints);
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } else {
      // setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch route: ${data['status']}")),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours > 0 ? '$hours hr ' : ''}${minutes} min';
  }

  Future<List<LatLng>> _decodePolyline(String encoded) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.decodePolyline(encoded);
    return result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<void> _addOptimizedMarkers(
    List<LatLng> points,
    List<dynamic> order,
  ) async {
    // Add origin marker (always first)
    markers.add(
      Marker(
        markerId: MarkerId('origin'),
        position: points.first,
        infoWindow: InfoWindow(title: 'Origin (1)'),
        icon: await _createNumberMarker(1, Colors.blue),
      ),
    );

    // Add optimized waypoint markers
    for (int i = 0; i < order.length; i++) {
      final pointIndex = order[i] + 1; // +1 because origin is 0
      markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: points[pointIndex],
          infoWindow: InfoWindow(title: 'Stop ${i + 2}'),
          icon: await _createNumberMarker(i + 2, Colors.green),
        ),
      );
    }

    // Add destination marker (always last)
    markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: points.last,
        infoWindow: InfoWindow(title: 'Destination (${points.length})'),
        icon: await _createNumberMarker(points.length, Colors.red),
      ),
    );
  }

  Future<BitmapDescriptor> _createNumberMarker(int number, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    const double size = 50.0;

    // Draw marker background
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw white border
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw number
    textPainter.text = TextSpan(
      text: number.toString(),
      style: TextStyle(
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
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;
    for (var point in points) {
      minLat =
          minLat == null
              ? point.latitude
              : (point.latitude < minLat ? point.latitude : minLat);
      maxLat =
          maxLat == null
              ? point.latitude
              : (point.latitude > maxLat ? point.latitude : maxLat);
      minLng =
          minLng == null
              ? point.longitude
              : (point.longitude < minLng ? point.longitude : minLng);
      maxLng =
          maxLng == null
              ? point.longitude
              : (point.longitude > maxLng ? point.longitude : maxLng);
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
