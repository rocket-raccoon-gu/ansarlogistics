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
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class DriverOrdersPageCubit extends Cubit<DriverOrdersPageState> {
  final PDApiGateway pdApiGateway;
  BuildContext context;

  DriverOrdersPageCubit(this.pdApiGateway, this.context, this.postRepositories)
    : super(DriverPageInitialState()) {
    loadPosts(0, "");
  }

  int page = 1;

  bool isLoadingMore = false;

  int currentval = -1;

  final PostRepositories postRepositories;

  List<Order> searchorderlist = [];

  List<Order> searchresult = [];

  bool searchvisible = false;

  void loadPosts(int count, String status) {
    try {
      if (state is DriverPageLoadingState) return;

      final currentstate = state;

      var oldpost = <Order>[];

      if (currentstate is DriverPageLoadedState) {
        oldpost = currentstate.posts;
      }

      if (count == 0) {
        oldpost.clear();
        UserController.userController.orderitems.clear();
        page = 1;
      } else {
        // UserController.userController.orderitems.addAll(oldpost);
      }

      emit(
        DriverPageLoadingState(
          oldpost == 0 ? [] : oldpost,
          isFirstFetch: page == 1,
        ),
      );

      log(status);

      if (!searchvisible) {
        postRepositories.fetchposts(page, 6, status).then((newpost) {
          page++;
          List<Order> posts = (state as DriverPageLoadingState).oldpost;

          posts.addAll(newpost);
          // }

          var postlist = posts.toSet().toList();

          emit(DriverPageLoadedState(postlist.toSet().toList()));
        });
      }
    } catch (e) {
      print(e);

      // emit(DriverPageLoadedState(UserController.userController.orderitems));
    }
  }

  updatesearchorder(List<Order> orderslist, String keyword) {
    searchresult.clear();
    searchorderlist.clear();

    final currentstate = state;

    if (currentstate is DriverPageLoadedState) {
      searchvisible = true;
    }
    if (orderslist.isEmpty) {
      // orderslist = UserController().orderitems;
    }
    if (keyword.isNotEmpty) {
      // UserController().orderitems.forEach((element) {
      //   if (element.subgroupIdentifier.startsWith(keyword.toString()) ||
      //       element.subgroupIdentifier.contains(keyword.toString())) {
      //     searchresult.add(element);
      //   }
      // });
    }

    if (searchresult.isNotEmpty) {
      emit(DriverPageLoadedState(searchresult));
    } else if (keyword.isNotEmpty && searchresult.isEmpty) {
      emit(DriverPageLoadedState(searchresult));
    } else if (keyword.isEmpty) {
      searchvisible = false;

      emit(DriverPageLoadedState(orderslist));
    }
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
          // Consider retry logic or fallback behavior here
        }
      } else {
        initializeService();
      }
    } catch (e) {
      log("Top level error in updateseekorder: $e");
    }
  }

  updatelocation(String latitude, String longitude) async {
    String? val = await PreferenceUtils.getDataFromShared("userid");

    final resp = await pdApiGateway.pickerDriverApi.updateDriverLocation(
      userId: int.parse(val!),
      latitude: latitude,
      longitude: longitude,
    );

    if (resp.statusCode == 200) {
      log("location updated");
    } else {
      log("error in updating location");
    }
  }
}
