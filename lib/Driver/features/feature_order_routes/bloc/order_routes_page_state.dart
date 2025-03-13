import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class OrderRoutesPageState {}

class OrderRoutesPageInitialState extends OrderRoutesPageState {
  // Define markers
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  OrderRoutesPageInitialState({required this.markers, required this.polylines});
}

class OrderRoutePageLoadingState extends OrderRoutesPageState {}
