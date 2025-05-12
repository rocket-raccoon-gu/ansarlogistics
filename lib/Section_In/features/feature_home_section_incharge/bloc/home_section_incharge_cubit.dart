import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/check_section_status_list.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';
import 'package:picker_driver_api/requests/update_section_request.dart';
import 'package:picker_driver_api/responses/branch_section_data_response.dart';

class HomeSectionInchargeCubit extends Cubit<HomeSectionInchargeState> {
  BuildContext context;
  final ServiceLocator serviceLocator;
  HomeSectionInchargeCubit(this.serviceLocator, this.context)
    : super(HomeSectionInchargeLoading()) {
    // updatecache();
    // UserController.userController.selectedprevselectindex = 0;
    // UserController.userController.selectedindex = 0;
    loadProducts();
  }

  Map<String, dynamic> map = {};

  Map<String, dynamic> map1 = {};

  Map<String, dynamic> map3 = {};

  List<Sectionitem> sectionitems = [];

  List<Sectionitem> searchresult = [];

  List<Sectionitem> searchsectionresult = [];

  List<NewStatus> newStatuses = [];

  List<Branchdatum> branchdata = [];

  List<Branchdatum> searchbranchlist = [];

  bool searchactive = false;

  List<Map<String, dynamic>> updateHistory = [];

  List<StatusHistory> statusHistories = [];

  loadProducts() async {
    try {
      sectionitems.clear();
      emit(HomeSectionInchargeLoading());

      updateHistory =
          (await PreferenceUtils.getstoremap(
            'updates_history',
          )).cast<Map<String, dynamic>>(); //

      log("history list : ${updateHistory}");

      final respdata = await serviceLocator.tradingApi.getSectionDataCheckList(
        UserController().profile.empId,
        UserController().profile.branchCode,
      );

      if (UserController.userController.profile.branchCode != "Q0113") {
        map3 = jsonDecode(respdata);

        if (map3.containsKey('data')) {
          CheckSectionstatusList checkSectionstatusList =
              CheckSectionstatusList.fromJson(map3);

          statusHistories = checkSectionstatusList.data;
        }
      }

      log(statusHistories.toString());

      // Rawdah Branch && Al Rayyan Branch data Fetch

      if (UserController.userController.profile.branchCode == "Q015" ||
          UserController.userController.profile.branchCode == "Q008") {
        final response = await serviceLocator.tradingApi.getSectionDataRequest(
          UserController.userController.userName,
          0,
        );

        log(response.toString());

        if (UserController.userController.profile.empId == "veg_rawdah" ||
            UserController.userController.profile.empId == "veg_rayyan") {
          map1 = jsonDecode(response);

          BranchSectionDataResponse branchSectionDataResponse =
              BranchSectionDataResponse.fromJson(map1);

          log(map1.toString());

          branchdata = branchSectionDataResponse.branchdata;

          if (branchdata.isNotEmpty) {
            UserController().branchdata = branchdata;
          }

          // UserController().branchdatalist = branchdata;
        } else {
          //   log(response.toString());

          map = jsonDecode(response);

          if (map["data"].isNotEmpty) {
            SectionItemResponse sectionItemResponse =
                await SectionItemResponse.fromJson(map);

            sectionitems = sectionItemResponse.data;

            UserController().sectionitems = sectionitems;
          }
        }

        emit(
          HomeSectionInchargeInitial(
            sectionitems: sectionitems,
            branchdata: branchdata,
          ),
        );
      } else {
        //
        // Barwa Branch and Al Khor Branch data Fetch

        final response = await serviceLocator.tradingApi.getSectionDataRequest(
          UserController.userController.userName,
          0,
        );

        log(response.toString());

        map = jsonDecode(response);

        if (map["data"].isNotEmpty) {
          SectionItemResponse sectionItemResponse =
              await SectionItemResponse.fromJson(map);

          sectionitems = sectionItemResponse.data;
        }

        UserController.userController.sectionitems = sectionitems;

        emit(
          HomeSectionInchargeInitial(
            sectionitems: sectionitems,
            branchdata: branchdata,
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "something went wrong..! Please Try Again...",
        ),
      );
      emit(
        HomeSectionInchargeInitial(
          sectionitems: sectionitems,
          branchdata: branchdata,
        ),
      );
    }
  }

  updateloadProducts(int catid) async {
    try {
      sectionitems.clear();
      emit(HomeSectionInchargeLoading());

      final response = await serviceLocator.tradingApi.getSectionDataRequest(
        UserController.userController.userName,
        catid,
      );

      log(response.toString());

      map = jsonDecode(response);

      if (map["data"].isNotEmpty) {
        SectionItemResponse sectionItemResponse =
            await SectionItemResponse.fromJson(map);

        sectionitems = sectionItemResponse.data;
      }

      UserController.userController.sectionitems = sectionitems;

      emit(
        HomeSectionInchargeInitial(
          sectionitems: sectionitems,
          branchdata: branchdata,
        ),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "something went wrong..! Please Try Again...",
        ),
      );
      emit(
        HomeSectionInchargeInitial(
          sectionitems: sectionitems,
          branchdata: branchdata,
        ),
      );
    }
  }

  addToStockStatusList(String sku, String status, String productname) async {
    // newStatuses
    //     .add(NewStatus(sku: sku, status: status, productname: productname));
    log(UserController.userController.userName);
    int catid = getUserCategory(UserController.userController.userName);

    log(catid.toString());

    try {
      UpdateSectionRequest updateSectionRequest = UpdateSectionRequest(
        categoryId: catid,
        userId: UserController.userController.profile.empId,
        branchCode: UserController.userController.profile.branchCode,
        newStatuses: [
          NewStatus(sku: sku, status: status, productname: productname),
        ],
      );

      final response = await serviceLocator.tradingApi.updateSectionDataRequest(
        updateSectionRequest: updateSectionRequest,
        branch: UserController.userController.profile.branchCode,
      );

      if (response.statusCode == 200) {
        if (UserController.userController.profile.branchCode != 'Q013') {
          // ignore: use_build_context_synchronously
          List<Map<String, dynamic>> existingUpdates =
              (await PreferenceUtils.getstoremap(
                'updates_history',
              )).cast<Map<String, dynamic>>();

          // Check if this SKU already exists in history
          final existingIndex = existingUpdates.indexWhere(
            (item) => item['sku'] == sku,
          );

          if (existingIndex >= 0) {
            // Update existing entry
            existingUpdates[existingIndex] = {
              ...existingUpdates[existingIndex], // Keep other fields
              'status': status, // Update status
              'timestamp': DateTime.now().toIso8601String(), // Update timestamp
            };
          } else {
            // Add new entry
            existingUpdates.add({
              'sku': sku,
              'status': status,
              'productname': productname,
              'branch': UserController.userController.profile.branchCode,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }

          await PreferenceUtils.storeListmap(
            'updates_history',
            existingUpdates,
          );
        }

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "Stock Updated..!"),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something went wrong ${e} ...!,Please Try again ",
        ),
      );
    }
  }

  updateSearchOrderAR(List<Branchdatum> branchdata, String keyword) async {
    searchbranchlist.clear();

    if (keyword.isNotEmpty) {
      if (!searchactive) {
        searchactive = true;
      }

      branchdata.forEach((element) {
        if (isNumeric(keyword)) {
          if (element.sku.startsWith(keyword.toString())) {
            searchbranchlist.add(element);
          }
        } else {
          if (element.productName.contains(
            capitalizeFirstLetter(keyword).toString(),
          )) {
            searchbranchlist.add(element);
            // searchresult.add(element);
          }
        }
      });
    }

    if (searchbranchlist.isNotEmpty) {
      emit(
        HomeSectionInchargeInitial(
          sectionitems: searchresult,
          branchdata: searchbranchlist,
        ),
      );
    } else if (keyword.isNotEmpty && searchresult.isEmpty) {
      emit(
        HomeSectionInchargeInitial(
          sectionitems: searchresult,
          branchdata: searchbranchlist,
        ),
      );
    } else if (keyword.isEmpty) {
      // searchvisible = false;
      branchdata = UserController().branchdata;

      searchactive = false;
      // orderslist.forEach(
      //   (element) {
      //     orderlist
      //         .add(NewOrdersModel.updateOrderModel(element, serviceLocator));
      //   },
      // );
      emit(
        HomeSectionInchargeInitial(
          sectionitems: UserController().sectionitems,
          branchdata: branchdata,
        ),
      );
    }
  }

  updatesearchorder(List<Sectionitem> sectionlist, String keyword) async {
    searchresult.clear();
    searchsectionresult.clear();

    final currentstate = state;

    if (keyword.isNotEmpty) {
      if (!searchactive) {
        searchactive = true;
      }

      sectionlist.forEach((element) {
        if (isNumeric(keyword)) {
          if (element.sku.startsWith(keyword.toString())) {
            searchresult.add(element);
          }
        } else {
          if (element.productName.contains(
            capitalizeFirstLetter(keyword).toString(),
          )) {
            searchresult.add(element);
            // searchresult.add(element);
          }
        }
      });
    }

    if (searchresult.isNotEmpty) {
      sectionlist = searchsectionresult;
      emit(
        HomeSectionInchargeInitial(
          sectionitems: searchresult,
          branchdata: branchdata,
        ),
      );
    } else if (keyword.isNotEmpty && searchresult.isEmpty) {
      emit(
        HomeSectionInchargeInitial(
          sectionitems: searchresult,
          branchdata: branchdata,
        ),
      );
      // }
      // });
    } else if (keyword.isEmpty) {
      // searchvisible = false;
      sectionlist = UserController().sectionitems;

      searchactive = false;
      // orderslist.forEach(
      //   (element) {
      //     orderlist
      //         .add(NewOrdersModel.updateOrderModel(element, serviceLocator));
      //   },
      // );
      emit(
        HomeSectionInchargeInitial(
          sectionitems: sectionlist,
          branchdata: branchdata,
        ),
      );
    }

    // emit(HomeSectionInchargeInitialstate(sectionitems: searchresult));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s) != null;
  }

  String capitalizeFirstLetter(String s) {
    if (s == null || s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  clearSectionData() async {
    try {
      await PreferenceUtils.removeDataFromShared('updates_history');

      final resp = await serviceLocator.tradingApi.cleatSectionData(
        UserController.userController.profile.empId,
        UserController.userController.profile.branchCode,
      );

      if (jsonDecode(resp)['success']) {
        loadProducts();

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "All data cleared"),
        );
      }
    } catch (e) {
      log("console error ${e.toString()}");
    }
  }
}
