import 'dart:developer';

import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_state.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderRoutesPageCubit extends Cubit<OrderRoutesPageState> {
  BuildContext context;
  Map<String, dynamic> mydata;
  OrderRoutesPageCubit(this.context, this.mydata)
    : super(OrderRoutePageLoadingState()) {
    loaddata();
  }

  List<Order>? orderitems = [];

  // Define markers
  final Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};

  List<LatLng> polydots = [];

  loaddata() async {
    String? latval = await PreferenceUtils.getDataFromShared("userlat");

    String? longval = await PreferenceUtils.getDataFromShared("userlong");

    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(
          double.parse(latval ?? "25.219163858951955"),
          double.parse(longval ?? "51.5022582495983"),
        ),
        infoWindow: InfoWindow(title: 'Delivery Starting Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );

    polydots.add(
      LatLng(
        double.parse(latval ?? "25.219163858951955"),
        double.parse(longval ?? "51.5022582495983"),
      ),
    );

    if (mydata.containsKey('data') && mydata['data'].isNotEmpty) {
      orderitems = mydata['data'];

      orderitems!.forEach((ord) {
        _markers.add(
          Marker(
            markerId: MarkerId("${ord.entityId}"),
            position: LatLng(
              double.parse(ord.latitude),
              double.parse(ord.longitude),
            ),
            infoWindow: InfoWindow(
              title: '${ord.subgroupIdentifier}',
              snippet: 'This is Your order Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );

        polydots.add(
          LatLng(double.parse(ord.latitude), double.parse(ord.longitude)),
        );
      });

      _polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: polydots,
          color: customColors().pacificBlue,
          width: 6,
        ),
      );
    }

    emit(OrderRoutesPageInitialState(markers: _markers, polylines: _polylines));
  }

  generateGoogleMapsUrl() {
    // Origin and Destination

    if (polydots.isEmpty) {
      throw Exception('The polydots list is empty');
    }

    final String origin =
        "${polydots.first.latitude},${polydots.first.longitude}";
    final String destination =
        "${polydots.last.latitude},${polydots.last.longitude}";

    // waypoints all intermediate
    final List<LatLng> waypoints = polydots.sublist(1, polydots.length - 1);

    String waypointsparam = waypoints
        .map((point) => "${point.latitude},${point.longitude}")
        .join('|');

    // Construct the URL
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving";

    // Append waypoints if they exist
    if (waypoints.isNotEmpty) {
      return "$googleMapsUrl&waypoints=$waypointsparam";
    }

    return googleMapsUrl;
  }

  generateWaseMapUrl() {
    if (polydots.isEmpty) {
      throw Exception('The polydots list is empty');
    }

    final String origin =
        "ll.${polydots.first.latitude},${polydots.first.longitude}";
    final String destination =
        "ll.${polydots.last.latitude},${polydots.last.longitude}";

    final String wazeMapsUrl =
        "https://www.waze.com/live-map/directions?to=${destination}&from=${origin}";

    return wazeMapsUrl;
  }

  void launchDirections(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw "Could not launch URL";
    }
  }
}
