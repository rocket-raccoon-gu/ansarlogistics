import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  List<Sectionitem> sectionitems = [];

  List<Sectionitem> searchresult = [];

  List<Sectionitem> searchsectionresult = [];

  List<NewStatus> newStatuses = [];

  List<Branchdatum> branchdata = [];

  List<Branchdatum> searchbranchlist = [];

  loadProducts() async {
    try {
      sectionitems.clear();
      emit(HomeSectionInchargeLoading());

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

          // UserController().branchdatalist = branchdata;
          // } else {
          //   log(response.toString());

          //   map = jsonDecode(response);

          //   if (map["items"].isNotEmpty) {
          //     SectionItemResponse sectionItemResponse =
          //         await SectionItemResponse.fromJson(map);

          //     sectionitems = sectionItemResponse.sectionitems;

          UserController().sectionitems = sectionitems;
          //   }
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

        // if (UserController.userController.loginResponse.profile.branchCode ==
        //     "Q009") {
        //   // Get the current date and time
        //   DateTime now = DateTime.now();

        //   // Get the date for the previous day and set the time to 00:00:00
        //   DateTime lastDay =
        //       DateTime(now.year, now.month, now.day - 1, 0, 0, 0);

        //   // Define the format
        //   DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

        //   // Format the dates
        //   String formattedNow = dateFormat.format(now);
        //   String formattedLastDay = dateFormat.format(lastDay);

        //   // Print the results
        //   print('Today\'s Date and Time: $formattedNow');
        //   print('Yesterday\'s Date and Time: $formattedLastDay');

        //   int category =
        //       getUserCategory(UserController().loginResponse.profile.empId);

        //   final sresponse = await serviceLocator.tradingApi
        //       .getBranchSectionRequest(
        //           category.toString(),
        //           formattedLastDay,
        //           formattedNow,
        //           UserController.userController.loginResponse.profile.empId);

        //   map1 = {"branchdata": jsonDecode(sresponse)};

        //   BranchSectionDataResponse branchSectionDataResponse =
        //       BranchSectionDataResponse.fromJson(map1);

        //   branchdata = branchSectionDataResponse.branchdata;

        //   // sectionitems.forEach((element) {
        //   //   branchdata.forEach((element1) {
        //   //     if (element.sku == element1.sku) {
        //   //       element.status = int.parse(element1.status);
        //   //     }
        //   //   });
        //   // });

        //   //
        //   // Barwa Branch and Al Khor Branch data Fetch
        //   //
        // }

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

      if (map["items"].isNotEmpty) {
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
        // ignore: use_build_context_synchronously
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

  updatesearchorder(List<Sectionitem> sectionlist, String keyword) async {
    searchresult.clear();
    searchsectionresult.clear();

    final currentstate = state;

    // searchsectionresult = sectionlist;

    // print(UserController().mainlist);

    // if (currentstate is NewOrderPageLoaded) {
    //   searchvisible = true;
    // }
    // if (sectionlist.isEmpty) {
    //   sectionitems = UserController().sectionitems;
    // }

    log(sectionlist.toString());

    if (keyword.isNotEmpty) {
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
}
