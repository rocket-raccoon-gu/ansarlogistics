import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/services/api_gateway.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/picker_driver_api.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PickerOrdersCubit extends Cubit<PickerOrdersState> {
  final PDApiGateway pdApiGateway;
  BuildContext context;

  PickerOrdersCubit(this.pdApiGateway, this.context, this.postRepositories)
    : super(PickerOrdersInitialState()) {
    loadPosts(0, "");
  }

  int page = 1;

  bool isLoadingMore = false;

  int currentval = -1;

  final PostRepositories postRepositories;

  List<Order> searchorderlist = [];

  List<Order> searchresult = [];

  bool searchvisible = false;

  void loadPosts(int count, String status) async {
    // For Pickers.............

    try {
      if (state is PickerOrdersLoadingState) return;

      final currentstate = state;

      var oldpost = <Order>[];

      if (currentstate is PickerOrdersLoadedState) {
        oldpost = currentstate.posts;
      }

      if (count == 0) {
        oldpost.clear();
        UserController.userController.orderitems.clear();
        page = 1;
      } else {
        UserController.userController.orderitems.addAll(oldpost);
      }
      if (!isClosed) {
        emit(
          PickerOrdersLoadingState(
            oldpost == 0 ? [] : oldpost,
            isFirstFetch: page == 1,
          ),
        );
      }

      log(status);

      UserController.userController.pickerindexlist.clear();

      UserController.userController.notavailableindexlist.clear();

      // if (!searchvisible) {
      postRepositories.fetchposts(page, 6, status).then((newpost) {
        page++;
        List<Order> posts = (state as PickerOrdersLoadingState).oldpost;

        posts.addAll(newpost);
        // }

        var postlist = posts.toSet().toList();
        if (!isClosed) {
          emit(PickerOrdersLoadedState(postlist.toSet().toList()));
        }
      });
    } catch (e) {
      // print(e);
      if (!isClosed) {
        emit(PickerOrdersLoadedState(UserController.userController.orderitems));
      }
    }
  }

  updatesearchorder(List<Order> orderslist, String keyword) {
    searchresult.clear();
    searchorderlist.clear();

    final currentstate = state;

    if (currentstate is PickerOrdersLoadedState) {
      searchvisible = true;
    }
    if (orderslist.isEmpty) {
      orderslist = UserController().orderitems;
    }
    if (keyword.isNotEmpty) {
      UserController().orderitems.forEach((element) {
        if (element.subgroupIdentifier.startsWith(keyword.toString()) ||
            element.subgroupIdentifier.contains(keyword.toString())) {
          searchresult.add(element);
        }
      });
    }

    if (searchresult.isNotEmpty) {
      emit(PickerOrdersLoadedState(searchresult));
    } else if (keyword.isNotEmpty && searchresult.isEmpty) {
      emit(PickerOrdersLoadedState(searchresult));
    } else if (keyword.isEmpty) {
      searchvisible = false;

      emit(PickerOrdersLoadedState(orderslist));
    }
  }

  // updatelocation(String lat, String long) async {
  //   String? val = await PreferenceUtils.getDataFromShared("userid");

  //   final resp = await pdApiGateway.pickerDriverApi.updateDriverLocation(
  //       userId: int.parse(val!), latitude: lat, longitude: long);

  //   if (resp.statusCode == 200) {
  //     log("location updated");
  //   } else {
  //     log("error in updating location");
  //   }
  // }
}
