import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart'
    show logout;
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart'
    show sessionTimeOutBottomSheet;
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/services/api_gateway.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/picker_driver_api.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickerOrdersCubit extends Cubit<PickerOrdersState> {
  final PDApiGateway pdApiGateway;
  BuildContext context;

  PickerOrdersCubit(this.pdApiGateway, this.context, this.postRepositories)
    : super(PickerOrdersInitialState()) {
    loadOrdersNew();
  }

  List<OrderNew> ordersNew = [];
  List<CategoryGroup> categoriesNew = [];
  // New: load from /api/picker/ordersnew (non-paginated)
  Future<void> loadOrdersNew() async {
    try {
      if (!isClosed) emit(PickerOrdersNewLoadingState());

      final resp = await postRepositories.fetchOrdersNew();

      if (resp != null && (resp.success ?? true)) {
        ordersNew = resp.data?.orders ?? [];
        categoriesNew = resp.data?.categories ?? [];

        if (!isClosed) {
          emit(
            PickerOrdersNewLoadedState(
              orders: ordersNew,
              categories: categoriesNew,
            ),
          );
        }
      } else {
        if (!isClosed)
          emit(
            PickerOrdersNewErrorState(resp?.message ?? 'Failed to load orders'),
          );
        if (!isClosed && resp?.message == "Expired token") {
          sessionTimeOutBottomSheet(
            context: context,
            inputWidget: SessionOutBottomSheet(
              onTap: () async {
                await PreferenceUtils.removeDataFromShared("userCode");
                await logout(context);
              },
            ),
          );
        }
      }
    } catch (e) {
      if (!isClosed) emit(PickerOrdersNewErrorState('Error: $e'));
    }
  }

  int page = 1;

  bool isLoadingMore = false;

  int currentval = -1;

  final PostRepositories postRepositories;

  List<Order> searchorderlist = [];

  List<Order> searchresult = [];

  bool searchvisible = false;

  void filterOrdersByStatus(String status) {
    if (status == 'all') {
      emit(
        PickerOrdersNewLoadedState(
          orders: ordersNew,
          categories: categoriesNew,
        ),
      );
      return;
    }

    final filteredOrders =
        ordersNew.where((order) {
          return order.status?.toLowerCase() == status.toLowerCase();
        }).toList();

    emit(
      PickerOrdersNewLoadedState(
        orders: filteredOrders,
        categories: categoriesNew,
      ),
    );
  }

  // New API data holders (optional, for local caching)

  // void loadPosts(int count, String status) async {
  //   // For Pickers.............

  //   try {
  //     if (state is PickerOrdersLoadingState) return;

  //     final currentstate = state;
  //     // Capture existing posts before we emit loading to avoid race conditions
  //     List<OrderNew> capturedOldPosts = <OrderNew>[];
  //     if (currentstate is PickerOrdersLoadedState) {
  //       capturedOldPosts = List<OrderNew>.from(currentstate.posts);
  //     }

  //     if (count == 0) {
  //       capturedOldPosts.clear();
  //       UserController.userController.orderitems.clear();
  //       page = 1;
  //     } else {
  //       UserController.userController.orderitems.addAll(capturedOldPosts);
  //     }
  //     if (!isClosed) {
  //       emit(
  //         PickerOrdersLoadingState(
  //           capturedOldPosts.isEmpty ? [] : capturedOldPosts,
  //           isFirstFetch: page == 1,
  //         ),
  //       );
  //     }

  //     log(status);

  //     UserController.userController.pickerindexlist.clear();

  //     UserController.userController.notavailableindexlist.clear();

  //     // if (!searchvisible) {
  //     postRepositories.fetchOrdersNew().then((newpost) {
  //       page++;
  //       // Use the captured list to avoid relying on current state type
  //       final List<OrderNew> combined = <OrderNew>[
  //         ...capturedOldPosts,
  //         // ...newpost,
  //       ];
  //       final List<OrderNew> unique = combined.toSet().toList();
  //       if (!isClosed) {
  //         emit(PickerOrdersLoadedState(unique));
  //       }
  //     });
  //   } catch (e) {
  //     // print(e);
  //     if (!isClosed) {
  //       emit(PickerOrdersLoadedState(UserController.userController.orderitems));
  //     }
  //   }
  // }

  // updatesearchorder(List<OrderNew> orderslist, String keyword) {
  //   searchresult.clear();
  //   searchorderlist.clear();

  //   final currentstate = state;

  //   if (currentstate is PickerOrdersLoadedState) {
  //     searchvisible = true;
  //   }
  //   if (orderslist.isEmpty) {
  //     orderslist = UserController().orderitems;
  //   }
  //   if (keyword.isNotEmpty) {
  //     UserController().orderitems.forEach((element) {
  //       if (element.subgroupIdentifier.startsWith(keyword.toString()) ||
  //           element.subgroupIdentifier.contains(keyword.toString())) {
  //         searchresult.add(element);
  //       }
  //     });
  //   }

  //   if (searchresult.isNotEmpty) {
  //     emit(PickerOrdersLoadedState(searchresult));
  //   } else if (keyword.isNotEmpty && searchresult.isEmpty) {
  //     emit(PickerOrdersLoadedState(searchresult));
  //   } else if (keyword.isEmpty) {
  //     searchvisible = false;

  //     emit(PickerOrdersLoadedState(orderslist));
  //   }
  // }

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
