import 'dart:developer';

import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/bottom_sheet/view_direction_sheet.dart';
import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/custom_app_bar_map.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderRoutesPage extends StatefulWidget {
  Map<String, dynamic> mapdate;
  OrderRoutesPage({super.key, required this.mapdate});

  @override
  State<OrderRoutesPage> createState() => _OrderRoutesPageState();
}

class _OrderRoutesPageState extends State<OrderRoutesPage> {
  late GoogleMapController mapController;

  final LatLng _initialPosition = const LatLng(
    25.2187,
    51.5020153,
  ); // Example: San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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
                        onMapCreated: _onMapCreated,
                        markers: state.markers,
                        polylines: state.polylines,
                        initialCameraPosition: CameraPosition(
                          target: state.markers.first.position,
                          zoom: 14,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 120,
                        child: BasketButtonwithIcon(
                          bgcolor: customColors().pacificBlue,
                          image: "assets/route.png",
                          text: "Go Direction",
                          textStyle: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                          onpress: () async {
                            // BlocProvider.of<OrderRoutesPageCubit>(context)
                            //     .launchDirections(context
                            //         .read<OrderRoutesPageCubit>()
                            //         .generateGoogleMapsUrl());

                            customShowModalBottomSheet(
                              context: context,
                              inputWidget: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                child: ViewDirectionRouteSheet(
                                  gurl:
                                      BlocProvider.of<OrderRoutesPageCubit>(
                                        context,
                                      ).generateGoogleMapsUrl(),
                                  waseurl:
                                      BlocProvider.of<OrderRoutesPageCubit>(
                                        context,
                                      ).generateWaseMapUrl(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return LoadingIndecator();
              }
            },
          ),
        ],
      ),
    );
  }
}
