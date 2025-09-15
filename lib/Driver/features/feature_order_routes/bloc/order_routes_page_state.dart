import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class OrderRoutesPageState {}

class OrderRoutesPageInitialState extends OrderRoutesPageState {
  // Define markers
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  String totalDistanceText = "";
  String totalDurationText = "";
  OrderRoutesPageInitialState({
    required this.markers,
    required this.polylines,
    required this.totalDistanceText,
    required this.totalDurationText,
  });
}

class OrderRoutesPageEmptyState extends OrderRoutesPageState {
  OrderRoutesPageEmptyState();
}

class OrderRoutePageLoadingState extends OrderRoutesPageState {}
