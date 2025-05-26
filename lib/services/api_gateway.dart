import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ansarlogistics/services/authentication_service.dart';
import 'package:ansarlogistics/services/crash_analytics.dart';
import 'package:ansarlogistics/utils/network/network_service_status.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:picker_driver_api/picker_driver_api.dart';
import 'package:picker_driver_api/requests/update_section_request.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:picker_driver_api/utils/utils.dart';

class PDApiGateway implements AuthenticationService {
  final PickerDriverApi pickerDriverApi;
  final StreamController<String> networkStreamController;
  PDApiGateway(this.pickerDriverApi, this.networkStreamController) {
    NetworkStatusService.networkStatusController.stream.listen((
      NetworkStatus status,
    ) {
      if (status == NetworkStatus.Online) {
        pickerDriverApi.networkOnline = true;
      } else if (status == NetworkStatus.Offline) {
        pickerDriverApi.networkOnline = false;
      }
    });
  }

  @override
  Future<String> generalSPService({required String endpoint}) {
    // TODO: implement generalSPService
    throw UnimplementedError();
  }

  @override
  Future<LoginResponse> loginRequest({
    required String userId,
    required String password,
    required String token,
    required String bearertoken,
    required String appversion,
  }) async {
    try {
      final response = await pickerDriverApi
          .loginService(
            password: password,
            userId: userId,
            token: token,
            bearertoken: bearertoken,
            appversion: appversion,
          )
          .catchError((e, trace) {
            fatalError(e.toString(), trace);
            networkStreamController.sink.add(e.toString());
            throw e;
          })
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                "The request timed out. Please try again.",
              );
            },
          );
      return response;
    } on TimeoutException catch (e) {
      log("TimeoutException: ${e.message}");
      networkStreamController.sink.add("Request timed out after 10 seconds.");
      throw e; // Optionally rethrow or handle gracefully
    } catch (e) {
      log("An error occurred: $e");
      serviceSendError("Login service Error: $e");
      rethrow;
    }
  }

  @override
  Future orderRequestService({
    required pagesize,
    required currentpage,
    required token,
    required role,
    required status,
  }) async {
    try {
      final response = await pickerDriverApi.OrderService(
            pagesize: pagesize,
            currentpage: currentpage,
            token: token,
            role: role,
            status: status,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          })
          .timeout(Duration(seconds: 15));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateItemStatusService({required body, required token}) async {
    try {
      final response = await pickerDriverApi
          .orderItemStatusUpdateService(body: body, token: token)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          })
          .timeout(Duration(seconds: 10));
      return response;
    } catch (e, stackTrace) {
      log('$stackTrace');
      serviceSendError('update order item status Error $e');
      rethrow;
    }
  }

  @override
  Future updatedocuments({
    required Uint8List imagebytes,
    required Uint8List imagebytesdSign,
    required Uint8List imagebytesqId,
    required String orderid,
    required int driverid,
  }) async {
    final response = await pickerDriverApi
        .uploadDocumentService(
          imagebytes,
          imagebytesdSign,
          imagebytesqId,
          orderid,
          driverid,
        )
        .catchError((e, trace) {
          networkStreamController.sink.add(e.toString());
          throw e;
        });
    return response;
  }

  @override
  Future orderItemRequestService({required orderid, required token}) async {
    try {
      final response = await pickerDriverApi.OrderItemsService(
            orderid: orderid,
            token: token,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          })
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              // Return a response-like object or throw a custom exception
              throw TimeoutException(
                "The request timed out. Please try again.",
              );
            },
          );
      return response;
    } on TimeoutException catch (e) {
      log("TimeoutException: ${e.message}");
      networkStreamController.sink.add("Request timed out after 10 seconds.");
      throw e; // Optionally rethrow or handle gracefully
    } catch (e) {
      serviceSendError("Order items service Error");
      rethrow;
    }
  }

  @override
  Future sendRescheduleRequest({
    required String orderid,
    required String deliverydate,
    required String timerange,
    required int userid,
    required bool candeliver,
  }) async {
    try {
      final response = await pickerDriverApi
          .rescheduleRequest(
            orderid: orderid,
            deliverydate: deliverydate,
            userid: userid,
            timerange: timerange,
            candeliver: candeliver,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      return response;
    } catch (e) {
      serviceSendError("Reschedule Request" + e.toString());
      rethrow;
    }
  }

  @override
  Future sendRescheduleRequestNOL({
    required String orderid,
    required String deliverydate,
    required bool candeliver,
    required String comment,
    required int userid,
  }) async {
    try {
      // serviceSend("Reshedule Request");
      final response = await pickerDriverApi
          .rescheduleRequestNOL(
            orderid: orderid,
            deliverydate: deliverydate,
            userid: userid,
            candeliver: candeliver,
            comment: comment,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      return response;
    } catch (e) {
      serviceSendError("send Scheduled Request For NOL");
      rethrow;
    }
  }

  @override
  Future updateMainOrderStat({
    required String orderid,
    required String orderstatus,
    required String comment,
    required String userid,
    required String latitude,
    required String longitude,
  }) async {
    try {
      final responce = await pickerDriverApi
          .updatemainorderstat(
            orderid: orderid,
            order_status: orderstatus,
            comment: comment,
            user_id: userid,
            latitude: latitude,
            longitude: longitude,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          })
          .timeout(Duration(seconds: 10));
      return responce;
    } catch (e) {
      serviceSendError("Status Update Failed");

      return "Retry";
    }
  }

  Future getSimiliarItemsRequest({required String productid}) async {
    try {
      final response = await pickerDriverApi
          .getsimilarProducts(product_id: productid)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("get similiar requesterror");
      rethrow;
    }
  }

  @override
  Future getProductdata({required String product_id, required token}) async {
    try {
      final response = await pickerDriverApi
          .generalProductService(endpoint: product_id, token: token)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("get products request error");
      rethrow;
    }
  }

  @override
  Future updateuserstat({required int user_id, required int status}) async {
    try {
      final response = await pickerDriverApi
          .updateUserStat(userid: user_id, status: status)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("status update request error");
      rethrow;
    }
  }

  @override
  Future requestlocationdetails({
    required String startlat,
    required String endlat,
    required String destlat,
    required String destlong,
  }) async {
    try {
      final response = await pickerDriverApi
          .getlocationdetails(startlat, endlat, destlat, destlong)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      return response;
    } catch (e) {
      serviceSendError("Location Details Request" + e.toString());
      rethrow;
    }
  }

  @override
  Future OrderREportService({
    required String startDate,
    required String endDate,
    required token,
  }) async {
    try {
      final response = await pickerDriverApi.OrderREportService(
        startDate: startDate,
        endDate: endDate,
        token: token,
      ).catchError((e, trace) {
        networkStreamController.sink.add(e.toString());
        throw e;
      });
      return response;
    } catch (e) {
      serviceSendError("Order Report Request" + e.toString());
      rethrow;
    }
  }

  @override
  Future updateDriverLocationdetails({
    required int userId,
    required String latitude,
    required String longitude,
  }) async {
    try {
      final response = await pickerDriverApi
          .updateDriverLocation(
            userId: userId,
            latitude: latitude,
            longitude: longitude,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      return response;
    } catch (e) {
      serviceSendError("Location Details Update Request" + e.toString());
      rethrow;
    }
  }

  @override
  Future sendNotificationRequest({
    required String bearertoken,
    required String devicetoken,
    required String title,
    required String body,
  }) async {
    try {
      final response = await pickerDriverApi
          .sendNotification(
            bearertoken: bearertoken,
            devicetoken: devicetoken,
            title: title,
            body: body,
          )
          .catchError((e, trace) {
            throw e;
          });

      return response;
    } catch (e) {
      serviceSendError("Secter Stock request send error");
      rethrow;
    }
  }

  @override
  Future statusHistoryRequest({required String orderid}) async {
    try {
      final response = await pickerDriverApi
          .getStatusHistoryData(orderid)
          .catchError((e, trace) {
            throw e;
          });

      return response;
    } catch (e) {
      serviceSendError("Secter Stock request send error");
      rethrow;
    }
  }

  Future getSectionDataRequest(String user, int catid) async {
    try {
      final response = await pickerDriverApi
          .getSectionData(user.toLowerCase(), catid)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("get Section Data Request Error");
      rethrow;
    }
  }

  Future getSectionDataCheckList(String user, String branch) async {
    try {
      final response = await pickerDriverApi
          .getSectionDataCheckList(branchcode: branch, userid: user)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("get Section Data Request Error");
      rethrow;
    }
  }

  Future cleatSectionData(String user, String branch) async {
    try {
      final response = await pickerDriverApi
          .clearStockData(branchcode: branch, userid: user)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("get Section Data Request Error");
      rethrow;
    }
  }

  Future updateSectionDataRequest({
    required UpdateSectionRequest updateSectionRequest,
    required String branch,
  }) async {
    try {
      final response = await pickerDriverApi
          .updateSectionData(
            updateSectionRequest: updateSectionRequest,
            branch: branch,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      //
      return response;
    } catch (e) {
      serviceSendError("update section data request");
      rethrow;
    }
  }

  Future setDriverRegister({required Map<String, dynamic> driverdata}) async {
    try {
      final response = await pickerDriverApi
          .driverRegisterService(driverdata: driverdata)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });

      return response;
    } catch (e) {
      serviceSendError("GetClient requesterror");
      rethrow;
    }
  }

  Future getLastId() async {
    try {
      final response = await pickerDriverApi.getLastID().catchError((e, trace) {
        networkStreamController.sink.add(e.toString());
        throw e;
      });
      //
      return response;
    } catch (e) {
      serviceSendError("get Last Data Request Error");
      rethrow;
    }
  }

  @override
  Future generalProductServiceGet({
    required String endpoint,
    required String token11,
  }) async {
    try {
      // String? token11 = await PreferenceUtils.getDataFromShared("usertoken");

      final responce = await pickerDriverApi
          .generalProductService(endpoint: endpoint, token: token11)
          .catchError((e) {
            networkStreamController.sink.add(e.toString());
            // throw e;
          });
      return responce;
    } catch (e) {
      serviceSendError("customer request Failed");
      return "";
    }
  }

  @override
  Future getProductServiceGet({
    required String endpoint,
    required String token11,
  }) async {
    try {
      final responce = await pickerDriverApi
          .getProductService(endpoint: endpoint, token: token11)
          .catchError((e) {});
      return responce;
    } catch (e) {
      serviceSendError("product request Failed");
      return "";
    }
  }

  Future checkbarcodeavailablity({required String sku}) async {
    try {
      final response = await pickerDriverApi
          .checkavailabilitybarcode(sku: sku)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });

      return response;
    } catch (e) {
      serviceSendError("Product Barcode Check Error..!");

      return "Retry";
    }
  }

  @override
  Future generalPromotionService({required String endpoint}) async {
    String? token11 = await PreferenceUtils.getDataFromShared("usertoken");
    try {
      final response = await pickerDriverApi
          .checkPromotionService(endpoint: endpoint)
          .catchError((e) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });

      return response;
    } catch (e) {
      serviceSendError("general PromotionService Error");
      return "";
    }
  }

  @override
  Future checkBarcodeDBService({required String endpoint}) async {
    try {
      log("🌐 API Call Started: checkBarcodeDB with endpoint -> $endpoint");
      // print("🌐 API Call Started: checkBarcodeDB with endpoint -> $endpoint");

      final response = await pickerDriverApi
          .checkBarcodeDB(endpoint: endpoint)
          .catchError((e) {
            log("❗ Network Error in checkBarcodeDB: $e");
            // print("❗ Network Error in checkBarcodeDB: $e");

            networkStreamController.sink.add(e.toString());
            throw e;
          });

      log("✅ API Response Received from checkBarcodeDB");
      // print("✅ API Response: $response");

      return response;
    } catch (e) {
      log("❌ Exception in checkBarcodeDBService: $e");
      // print("❌ Exception in checkBarcodeDBService: $e");

      serviceSendError("get BarcodeDB Error");
      return "";
    }
  }

  Future addtoProductList({
    required List<Map<String, dynamic>> dynamiclist,
  }) async {
    try {
      final response = await pickerDriverApi
          .addtoproductlist(dynamiclist: dynamiclist)
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
            throw e;
          });
      // print(dynamiclist);
      return response;
    } catch (e) {
      serviceSendError("Product Add To List API Error");

      return "Retry";
    }
  }

  Future updateBarcodeLog({
    required orderid,
    required String sku,
    required String scanned_sku,
    required String user_id,
  }) async {
    try {
      final response = await pickerDriverApi
          .updateBarcodeLog(
            orderid: orderid,
            sku: sku,
            scanned_sku: scanned_sku,
            user_id: user_id,
          )
          .catchError((e, trace) {
            networkStreamController.sink.add(e.toString());
          });

      return response;
    } catch (e) {
      serviceSendError("Update Barcode Log API Error");

      return "Retry";
    }
  }

  Future getCompanyList() async {
    try {
      final response = await pickerDriverApi.getCompanyList().catchError((
        e,
        trace,
      ) {
        networkStreamController.sink.add(e.toString());
      });

      return response;
    } catch (e) {
      serviceSendError("get Company List Api Error");

      return "Retry";
    }
  }
}
