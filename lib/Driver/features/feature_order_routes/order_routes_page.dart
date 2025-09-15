import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/custom_app_bar_map.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderRoutesPage extends StatefulWidget {
  final Map<String, dynamic> mapdate;
  const OrderRoutesPage({super.key, required this.mapdate});

  @override
  State<OrderRoutesPage> createState() => _OrderRoutesPageState();
}

class _OrderRoutesPageState extends State<OrderRoutesPage> {
  final LatLng _initialPosition = const LatLng(
    25.2187,
    51.5020153,
  ); // Example: San Francisco

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColors().backgroundPrimary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      body: Column(
        children: [
          CustomAppBarMap(
            onTapBack: () async {
              // BlocProvider.of<NavigationCubit>(context).updateWatchList(0);
              context.gNavigationService.back(context);
            },
          ),

          BlocBuilder<OrderRoutesPageCubit, OrderRoutesPageState>(
            builder: (context, state) {
              if (state is OrderRoutesPageInitialState) {
                return Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          context.read<OrderRoutesPageCubit>().onMapCreated(
                            controller,
                          );
                        },
                        markers: state.markers,
                        polylines: state.polylines,
                        initialCameraPosition: CameraPosition(
                          target:
                              state.markers.isNotEmpty
                                  ? state.markers.first.position
                                  : _initialPosition,
                          zoom: 12,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          color: customColors().backgroundPrimary,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Total Distance: ${state.totalDistanceText} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "Total Duration: ${state.totalDurationText} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is OrderRoutePageLoadingState) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                );
              } else {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("No Cordinates Found")],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
