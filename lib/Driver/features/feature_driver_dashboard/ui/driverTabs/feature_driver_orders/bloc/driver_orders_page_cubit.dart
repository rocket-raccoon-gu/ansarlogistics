import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Driver/background_service/background_service.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_orders/bloc/driver_orders_page_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/api_gateway.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/picker_driver_api.dart';
import 'package:toastification/toastification.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class DriverOrdersPageCubit extends Cubit<DriverOrdersPageState> {
  final PDApiGateway pdApiGateway;
  BuildContext context;

  DriverOrdersPageCubit(this.pdApiGateway, this.context, this.postRepositories)
    : super(DriverPageInitialState()) {
    loadPosts(0, "");
  }

  int page = 1;

  bool isLoadingMore = false;

  bool hasMore = true;

  static const int pageSize = 8;

  int currentval = -1;

  final PostRepositories postRepositories;

  List<DataItem> searchorderlist = [];

  List<DataItem> searchresult = [];

  List<DataItem> allOrders = [];

  bool searchvisible = false;

  void loadPosts(int count, String status) async {
    if (isClosed) return;
    if (state is DriverPageLoadingState) return;

    final currentstate = state;
    var oldpost = <DataItem>[];

    if (currentstate is DriverPageLoadedState) {
      oldpost = List<DataItem>.from(currentstate.posts);
      if (count != 0 && !currentstate.hasMore) return;
    }

    if (count != 0 && !hasMore) return;

    if (count == 0) {
      oldpost.clear();
      allOrders.clear();
      searchvisible = false;
      page = 1;
      hasMore = true;
    }

    isLoadingMore = count != 0;
    emit(DriverPageLoadingState(oldpost, isFirstFetch: page == 1));

    try {
      final newpost = await postRepositories.fetchposts(page, pageSize, status);
      if (isClosed) return;

      final posts = List<DataItem>.from(oldpost);
      var added = 0;
      for (final item in newpost) {
        final exists = posts.any(
          (existing) =>
              existing.order.subgroupIdentifier ==
              item.order.subgroupIdentifier,
        );
        if (!exists) {
          posts.add(item);
          added++;
        }
      }

      page++;
      hasMore =
          added > 0 && postRepositories.postService.lastHasMore;
      if (newpost.isEmpty || newpost.length < pageSize) {
        hasMore = false;
      }
      allOrders = posts;
      isLoadingMore = false;
      emit(DriverPageLoadedState(posts, hasMore: hasMore));
    } catch (e) {
      log('Driver orders fetch failed: $e');
      if (isClosed) return;
      isLoadingMore = false;
      hasMore = false;
      emit(DriverPageLoadedState(oldpost, hasMore: false));
    }
  }

  updatesearchorder(List<DataItem> orderslist, String keyword) {
    searchresult.clear();
    searchorderlist.clear();

    final source = allOrders.isNotEmpty ? allOrders : orderslist;

    if (keyword.isNotEmpty) {
      searchvisible = true;
      searchresult =
          source
              .where(
                (element) =>
                    element.order.subgroupIdentifier.toUpperCase().contains(
                      keyword.toUpperCase(),
                    ) ||
                    element.order.merchantOrderId.toUpperCase().contains(
                      keyword.toUpperCase(),
                    ) ||
                    element.order.subgroupIdentifiers.any(
                      (id) => id.toUpperCase().contains(keyword.toUpperCase()),
                    ),
              )
              .toList();
      emit(DriverPageLoadedState(searchresult, hasMore: false));
      return;
    }

    searchvisible = false;
    emit(DriverPageLoadedState(source, hasMore: hasMore));
  }

  Future<void> requestPermission() async {
    var status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  updateseekorder() async {
    try {
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();

      if (isRunning) {
        log("Service Already Running...!");

        if (!isClosed) {
          emit(DriverOrderSeekLoadingState());
        }

        // Check permission first
        final locationPermission = await Permission.location.status;
        if (!locationPermission.isGranted) {
          requestPermission();
          emit(DriverPageLoadedState([]));
          return;
        }

        try {
          // Use getLastKnownPosition first for faster response
          Position? position = await Geolocator.getLastKnownPosition();
          position ??= await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10), // Add timeout
          );

          log(
            "granted ${position.latitude},${position.longitude} ...${DateTime.now()}",
          );

          // Parallelize storage operations
          await Future.wait<dynamic>([
            PreferenceUtils.storeDataToShared(
              "userlat",
              position.latitude.toString(),
            ),
            PreferenceUtils.storeDataToShared(
              "userlong",
              position.longitude.toString(),
            ),
          ]);

          String? token = await PreferenceUtils.getDataFromShared("usertoken");

          // Update controller
          UserController.userController
            ..locationlatitude = position.latitude.toString()
            ..locationlongitude = position.longitude.toString();

          // Make API call
          final resp = await pdApiGateway
              .updateDriverLocationdetails(
                userId: UserController.userController.profile.id,
                latitude: position.latitude.toString(),
                longitude: position.longitude.toString(),
                token: token!,
              )
              .timeout(Duration(seconds: 15)); // Add timeout

          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            log("${data['message']} ${DateTime.now()}");

            final isSuccess = data['message'].toString().contains('updated');
            toastification.show(
              backgroundColor:
                  isSuccess ? customColors().success : customColors().danger,
              title: TranslatedText(
                text: isSuccess ? "Location Update" : "Location Warning...!",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
              description: TranslatedText(
                text: data['message'],
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.White,
                ),
              ),
              autoCloseDuration: Duration(seconds: 10),
            );
          } else {
            log("location update force have issue.... ${DateTime.now()}");
          }

          loadPosts(0, '');
        } catch (e) {
          log("Error in location update: $e");
          if (!isClosed) {
            loadPosts(0, '');
          }
        }
      } else {
        initializeService();
        if (!isClosed) {
          loadPosts(0, '');
        }
      }
    } catch (e) {
      log("Top level error in updateseekorder: $e");
    }
  }

  updatelocation(String latitude, String longitude) async {
    String? val = await PreferenceUtils.getDataFromShared("userid");

    final String? token = await PreferenceUtils.getDataFromShared("usertoken");

    final resp = await pdApiGateway.pickerDriverApi.updateDriverLocation(
      userId: int.parse(val!),
      latitude: latitude,
      longitude: longitude,
      token1: token!,
    );

    if (resp.statusCode == 200) {
      log("location updated");
    } else {
      log("error in updating location");
    }
  }
}
