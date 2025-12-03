import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
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
import 'package:picker_driver_api/responses/stock_update.dart';

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

  List<StockUpdate> stockUpdates = [];

  // Getter to convert StockUpdate objects to maps for UI compatibility
  List<Map<String, dynamic>> get stockUpdatesAsMaps =>
      stockUpdates.map((update) => update.toMap()).toList();

  // loadProducts() async {
  //   try {
  //     // print("🔄 Clearing existing section items...");
  //     sectionitems.clear();
  //     emit(HomeSectionInchargeLoading());

  //     // print("📦 Fetching update history from preferences...");
  //     updateHistory =
  //         (await PreferenceUtils.getstoremap(
  //           'updates_history',
  //         )).cast<Map<String, dynamic>>();
  //     // print("🕘 History List: $updateHistory");

  //     // print("🌐 Calling getSectionDataCheckList API...");
  //     final respdata = await serviceLocator.tradingApi.getSectionDataCheckList(
  //       UserController().profile.empId,
  //       UserController().profile.branchCode,
  //       UserController().profile.categoryIds,
  //     );

  //     if (UserController.userController.profile.branchCode != "Q0113") {
  //       // print("📥 Decoding JSON response from checklist API...");
  //       map3 = jsonDecode(respdata);

  //       if (map3.containsKey('data')) {
  //         CheckSectionstatusList checkSectionstatusList =
  //             CheckSectionstatusList.fromJson(map3);
  //         statusHistories = checkSectionstatusList.data;
  //         // print("✅ statusHistories loaded: $statusHistories");
  //       } else {
  //         // print("❌ 'data' key missing in checklist response");
  //       }
  //     }

  //     // print("${UserController.userController.profile.branchCode} branchCode");

  //     // Rawdah Branch && Al Rayyan Branch data Fetch
  //     if (UserController.userController.profile.branchCode == "Q015" ||
  //         UserController.userController.profile.branchCode == "Q008") {
  //       print(
  //         "🏪 Fetching branch-specific section data for Rawdah or Rayyan...",
  //       );
  //       final response = await serviceLocator.tradingApi.getSectionDataRequest(
  //         UserController.userController.userName,
  //         0,
  //         UserController().profile.categoryIds,
  //         UserController().profile.branchCode,
  //       );

  //       // print("🏪 ${jsonEncode(response)} Fetching Rawdah or Rayyan...");

  //       if (UserController.userController.profile.empId == "veg_rawdah" ||
  //           UserController.userController.profile.empId == "veg_rayyan") {
  //         map1 = jsonDecode(response);
  //         // map1.forEach((key, value) {
  //         //   print("Key: $key");

  //         //   // If value is Map or List, encode as JSON string for full detail
  //         //   // if (value is Map || value is List) {
  //         //   //   print("Value: ${jsonEncode(value)}");
  //         //   // } else {
  //         //   //   print("Value: $value");
  //         //   // }

  //         //   // print("-----");
  //         // });
  //         BranchSectionDataResponse branchSectionDataResponse =
  //             BranchSectionDataResponse.fromJson(map1);

  //         // print("✅ Branch data loaded: ${map1.toString()}");

  //         branchdata = branchSectionDataResponse.branchdata;

  //         if (branchdata.isNotEmpty) {
  //           // print("🟢 Setting branch data in controller...");
  //           UserController().branchdata = branchdata;
  //         }
  //       } else {
  //         map = jsonDecode(response);
  //         if (map["data"].isNotEmpty) {
  //           SectionItemResponse sectionItemResponse =
  //               await SectionItemResponse.fromJson(map);

  //           sectionitems = sectionItemResponse.data;
  //           // print("✅ Section Items loaded: ${sectionitems.length} items");
  //           // for (var item in sectionitems) {
  //           //   print("🔸 Sectionitem: ${item.toJson()}");
  //           // }
  //           UserController().sectionitems = sectionitems;
  //         }
  //       }

  //       emit(
  //         HomeSectionInchargeInitial(
  //           sectionitems: sectionitems,
  //           branchdata: branchdata,
  //         ),
  //       );
  //     } else {
  //       // Barwa Branch and Al Khor Branch data Fetch
  //       print("🏬 Fetching section data for Barwa or Al Khor...");
  //       final response = await serviceLocator.tradingApi.getSectionDataRequest(
  //         UserController.userController.userName,
  //         0,
  //         UserController().profile.categoryIds,
  //         UserController().profile.branchCode,
  //       );

  //       // print("📩 Raw section data response: $response");

  //       final testMap = jsonDecode(response);
  //       // print("${testMap["data"]} 🔸 rawDataList");

  //       if (testMap["data"].isNotEmpty) {
  //         SectionItemResponse sectionItemResponse =
  //             SectionItemResponse.fromJson(testMap);

  //         List<Sectionitem> tempItems = sectionItemResponse.data;
  //         // print("🔍 Looping through loaded section items...");
  //         // for (var item in tempItems) {
  //         //   print("${item.toJson()} ✅ sectionItem");
  //         // }
  //       }

  //       map = jsonDecode(response);
  //       if (map["data"].isNotEmpty) {
  //         SectionItemResponse sectionItemResponse =
  //             await SectionItemResponse.fromJson(map);
  //         sectionitems = sectionItemResponse.data;
  //         // print("✅ Final sectionitems assigned: ${sectionitems.length}");
  //       }

  //       UserController.userController.sectionitems = sectionitems;

  //       emit(
  //         HomeSectionInchargeInitial(
  //           sectionitems: sectionitems,
  //           branchdata: branchdata,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     // print("❌ Error during loadProducts: ${e.toString()}");

  //     showSnackBar(
  //       context: context,
  //       snackBar: showErrorDialogue(
  //         errorMessage: "something went wrong..! Please Try Again...",
  //       ),
  //     );
  //     emit(
  //       HomeSectionInchargeInitial(
  //         sectionitems: sectionitems,
  //         branchdata: branchdata,
  //       ),
  //     );
  //   }
  // }

  loadProducts() async {
    try {
      // print("🟡 loadProducts started");

      sectionitems.clear();
      // print("🧹 Cleared section items");

      emit(HomeSectionInchargeLoading());
      // print("📡 Emitted HomeSectionInchargeLoading state");

      // Load local update history
      updateHistory =
          (await PreferenceUtils.getstoremap(
            'updates_history',
          )).cast<Map<String, dynamic>>();
      // print("🗂️ Loaded update history: $updateHistory");

      // Always call checklist API first to get status history
      // print("📋 Calling getSectionDataCheckList...");

      log("${UserController().profile.categoryIds}");

      final checklistResponse = await serviceLocator.tradingApi
          .getSectionDataCheckList(
            UserController().profile.empId,
            UserController().profile.branchCode,
            UserController().profile.categoryIds,
          );

      final checklistMap = jsonDecode(checklistResponse);
      if (checklistMap.containsKey('data')) {
        CheckSectionstatusList checkSectionstatusList =
            CheckSectionstatusList.fromJson(checklistMap);
        statusHistories = checkSectionstatusList.data;
        // print("✅ Loaded statusHistories: ${statusHistories.length} items");
      } else {
        // print("⚠️ Checklist response missing 'data' key");
      }

      // Unified API call for all branches
      // print("🌐 Calling getSectionDataRequest...");
      final response = await serviceLocator.tradingApi.getSectionDataRequest(
        UserController().profile.name,
        0,
        UserController().profile.categoryIds,
        UserController().profile.branchCode,
      );

      final dataMap = jsonDecode(response);
      if (dataMap["data"].isNotEmpty) {
        // print("📦 Section data received, parsing...");

        if ((UserController().profile.branchCode == "Q015" ||
                UserController().profile.branchCode == "Q008") &&
            (UserController().profile.empId == "veg_rayyan" ||
                UserController().profile.empId == "veg_rawdah")) {
          BranchSectionDataResponse branchSectionDataResponse =
              BranchSectionDataResponse.fromJson(dataMap);
          branchdata = branchSectionDataResponse.data;

          UserController().branchdata = branchdata;
        } else {
          SectionItemResponse sectionItemResponse =
              SectionItemResponse.fromJson(dataMap);
          sectionitems = sectionItemResponse.data;
          UserController().sectionitems = sectionitems;
        }

        // print("✅ Section items loaded: ${sectionitems.length}");
      } else {
        // print("⚠️ No section items found in response");
      }

      emit(
        HomeSectionInchargeInitial(
          sectionitems: sectionitems,
          branchdata: branchdata, // No branch-specific logic anymore
        ),
      );
      // print(
      //   "✅ Emitted HomeSectionInchargeInitial with ${sectionitems.length} items",
      // );
    } catch (e) {
      // print("❌ Error in loadProducts: $e");

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something went wrong..! Please try again...",
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
        catid == 0 ? UserController().profile.categoryIds : catid.toString(),
        UserController().profile.branchCode,
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

  Future<void> addToStockStatusList(
    String sku,
    String status,
    String productname,
    String imageUrl,
  ) async {
    try {
      // print("👤 User: ${UserController.userController.userName}");

      int catid = getUserCategory(UserController.userController.userName);
      // print("📦 Category ID: $catid");

      // Prepare the request
      final updateSectionRequest = UpdateSectionRequest(
        categoryId: catid,
        userId: UserController.userController.profile.empId,
        branchCode: UserController.userController.profile.branchCode,
        newStatuses: [
          NewStatus(sku: sku, status: status, productname: productname),
        ],
        branch: UserController.userController.profile.branchCode,
      );

      // print(
      //   "📤 Sending updateSectionRequest: ${updateSectionRequest.toJson()}",
      // );

      // Call the API
      final response = await serviceLocator.tradingApi.updateSectionDataRequest(
        updateSectionRequest: updateSectionRequest,
        branch: UserController.userController.profile.branchCode,
      );

      if (response.statusCode == 200) {
        // print("✅ Stock update succeeded for SKU: $sku");

        updateItemStatus(
          sku,
          productname,
          imageUrl,
          status == "1" ? true : false,
        );

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(
            message: "Stock status updated successfully.",
          ),
        );
      } else {
        // print("❌ API Error: Status code ${response.statusCode}");

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage:
                "Failed to update stock status. Please try again later.",
          ),
        );
      }
    } catch (e) {
      // print("🔥 Exception during API call: $e");

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something went wrong. Please try again.\nError: $e",
        ),
      );
    }
  }

  updateSearchOrderAR(List<Branchdatum> branchdata, String keyword) async {
    searchbranchlist.clear();
    // print("two");

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

  // void updateItemStatus(
  //   String sku,
  //   String name,
  //   String imageUrl,
  //   bool isEnabled,
  // ) {
  //   // Check if this item already has an update
  //   final existingIndex = stockUpdates.indexWhere((item) => item.sku == sku);

  //   if (existingIndex >= 0) {
  //     // Update existing entry
  //     stockUpdates[existingIndex] = StockUpdate(
  //       sku: sku,
  //       name: name,
  //       imageUrl: "${mainimageurl}${imageUrl}",
  //       isEnabled: isEnabled,
  //       updatedAt: DateTime.now(),
  //     );
  //   } else {
  //     // Add new entry
  //     stockUpdates.add(
  //       StockUpdate(
  //         sku: sku,
  //         name: name,
  //         imageUrl: imageUrl,
  //         isEnabled: isEnabled,
  //         updatedAt: DateTime.now(),
  //       ),
  //     );
  //   }

  //   // Also update updateHistory for UI compatibility
  //   final historyIndex = updateHistory.indexWhere((item) => item['sku'] == sku);
  //   final newUpdateEntry = {
  //     'sku': sku,
  //     'name': name,
  //     'imageUrl': imageUrl,
  //     'isEnabled': isEnabled,
  //     'updatedAt': DateTime.now().toIso8601String(),
  //     'branch': UserController().profile.branchCode,
  //   };

  //   if (historyIndex >= 0) {
  //     updateHistory[historyIndex] = newUpdateEntry;
  //   } else {
  //     updateHistory.add(newUpdateEntry);
  //   }

  //   emit(state); // Trigger a rebuild
  // }

  void updateItemStatus(
    String sku,
    String name,
    String imageUrl,
    bool isEnabled,
  ) async {
    // 1) Update in-memory sectionitems list
    final index = sectionitems.indexWhere((item) => item.sku == sku);
    if (index != -1) {
      final item = sectionitems[index];
      sectionitems[index] = Sectionitem(
        sku: item.sku,
        productName: item.productName,
        imageUrl: item.imageUrl,
        stockQty: item.stockQty,
        isInStock: isEnabled ? 1 : 0,
        // copy over any other required fields here
      );
    }

    // 1b) If you use searchresult for the current view, update that too
    final searchIndex = searchresult.indexWhere((item) => item.sku == sku);
    if (searchIndex != -1) {
      final item = searchresult[searchIndex];
      searchresult[searchIndex] = Sectionitem(
        sku: item.sku,
        productName: item.productName,
        imageUrl: item.imageUrl,
        stockQty: item.stockQty,
        isInStock: isEnabled ? 1 : 0,
        // copy the rest
      );
    }

    // Keep UserController in sync if UI reads from it
    UserController().sectionitems = sectionitems;

    // 2) Your existing stockUpdates / updateHistory logic (keep as is)
    final existingIndex = stockUpdates.indexWhere((item) => item.sku == sku);
    if (existingIndex >= 0) {
      stockUpdates[existingIndex] = StockUpdate(
        sku: sku,
        name: name,
        imageUrl: "${mainimageurl}${imageUrl}",
        isEnabled: isEnabled,
        updatedAt: DateTime.now(),
      );
    } else {
      stockUpdates.add(
        StockUpdate(
          sku: sku,
          name: name,
          imageUrl: "${mainimageurl}${imageUrl}",
          isEnabled: isEnabled,
          updatedAt: DateTime.now(),
        ),
      );
    }

    final historyIndex = updateHistory.indexWhere((item) => item['sku'] == sku);
    final newUpdateEntry = {
      'sku': sku,
      'name': name,
      'imageUrl': imageUrl,
      // 'isEnabled': isEnabled,
      'status': isEnabled ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
      'branch': UserController().profile.branchCode,
    };

    if (historyIndex >= 0) {
      updateHistory[historyIndex] = newUpdateEntry;
    } else {
      updateHistory.add(newUpdateEntry);
    }

    await PreferenceUtils.storeListmap('updates_history', updateHistory);

    // 3) Emit a fresh state so BlocBuilder rebuilds with updated list
    emit(
      HomeSectionInchargeInitial(
        sectionitems: sectionitems,
        branchdata: branchdata,
      ),
    );
  }

  Future<void> addNewTempItem({
    required String sku,
    required String name,
  }) async {
    // 1) Save to shared preferences
    final rawList = await PreferenceUtils.getstoremap('new_section_items');
    final List<Map<String, dynamic>> tempItems =
        rawList.cast<Map<String, dynamic>>();

    tempItems.add({
      'sku': sku,
      'productName': name,
      'status': 3, // NEW
    });

    await PreferenceUtils.storeListmap('new_section_items', tempItems);

    // 2) Append to section list for immediate UI
    final newItem = Sectionitem(
      sku: sku,
      productName: name,
      // Fill these with safe defaults from your Sectionitem model:
      imageUrl: '',
      stockQty: '0',
      isInStock: 1,
      // add any other required fields here
    );

    sectionitems.add(newItem);
    UserController().sectionitems = sectionitems;

    // 3) Append to statusHistories so PDF sees it as NEW (status 3)
    statusHistories.add(
      StatusHistory(
        id: 0,
        categoryId: 0,
        productName: name,
        sku: sku,
        status: 3,
        userId: UserController().profile.empId,
        branchCode: UserController().profile.branchCode,
        updatedAt: DateTime.now(),
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
