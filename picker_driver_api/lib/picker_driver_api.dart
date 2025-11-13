library picker_driver_api;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:picker_driver_api/requests/update_section_request.dart';
import 'package:picker_driver_api/responses/base_response.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:picker_driver_api/utils/utils.dart';

import 'requests/login_request.dart' as loginRequestModel;

import 'package:uuid/uuid.dart';
import 'picker_driver_api_platform_interface.dart';

part 'utils/debuggable_client.dart';
part 'endpoints.dart';
part 'responses/failure.dart';

class ContentTypes {
  static const String applicationCharset = "application/json;charset=UTF-8";
  static const String applicationJson = "application/json";
  static const String formurlencoded = "application/x-www-form-urlencoded";
}

var mainbaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: "https://pickerdriver-api.testuatah.com/api/",
);
var mainapplicationPath = String.fromEnvironment(
  'APPLICATION_PATH',
  defaultValue: "/v1/",
);

String productUrl1 = 'https://www.ansargallery.com/rest/V1/';

const Duration timeoutDuration = Duration(seconds: 30);

class PickerDriverApi {
  final String applicationPath;
  final Uri baseUrl;
  final Uri productUrl;
  final http.Client _client;

  String cookie = "";
  String fullcookie = "";
  String token = "";

  bool networkOnline = true;

  PickerDriverApi(
    this.baseUrl,
    this.productUrl,
    this.applicationPath,
    this._client,
  );

  factory PickerDriverApi.create({
    required String baseUrl,
    required String productUrl,
    required String applicationPath,
    Duration connectionTimeout = timeoutDuration,
  }) {
    return PickerDriverApi(
      Uri.parse(baseUrl),
      Uri.parse(productUrl), //'xlrds/webresources/SearchSymbol',
      applicationPath,
      IOClient(HttpClient()),
    );
  }

  factory PickerDriverApi.debuggable({
    required String baseUrl,
    required String productUrl,
    required String applicationPath,
    Duration connectionTimeout = timeoutDuration,
  }) {
    HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = connectionTimeout;
    return PickerDriverApi(
      Uri.parse(baseUrl), //'xlrds/webresources/SearchSymbol',
      Uri.parse(productUrl),
      applicationPath,
      _DebuggableClient(IOClient(HttpClient())),
    );
  }

  factory PickerDriverApi.proxy({
    required String baseUrl,
    required String productUrl,
    required String applicationPath,
    required String proxyIp,
    Duration connectionTimeout = timeoutDuration,
  }) {
    HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = connectionTimeout;
    httpClient.findProxy = (uri) {
      return "PROXY $proxyIp:8888;";
    };
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => Platform.isAndroid);
    return PickerDriverApi(
      Uri.parse(productUrl),
      Uri.parse(baseUrl), //'xlrds/webresources/SearchSymbol',
      applicationPath,
      IOClient(httpClient),
    );
  }

  // New orders (non-paginated) endpoint for picker with categories + orders
  Future<http.Response> OrdersNewService({required String token}) async {
    // Direct API host for new picker endpoint
    final Uri url = _endpointWithApplicationPath("picker/ordersnew");

    log(url.toString());
    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    try {
      serviceSend("OrdersNew service send");
      return _handleRequest(
        onRequest: () => _client.get(url, headers: headers),
        onResponse: (response) {
          return response;
        },
      );
    } catch (e) {
      serviceSendError("OrdersNew service error");
      rethrow;
    }
  }

  Future<String?> getPlatformVersion() {
    return PickerDriverApiPlatform.instance.getPlatformVersion();
  }
}

extension PDGeneralApi on PickerDriverApi {
  Future<String> generalService({
    required String endpoint,
    required String token,
  }) async {
    final url = _endpointWithApplicationPath(_ordersService + endpoint);
    // final generalRequest =
    //     GeneralRequest(proc: "general_service", request: request);
    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    // print("my path" + url.toString());

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future<LoginResponse> loginService({
    required String userId,
    required String password,
    required String token,
    required String bearertoken,
    required String appversion,
  }) async {
    // Uri url = Uri.parse(_endpointWithApplicationPathString('pk_dv_login.php'));

    Uri url = _endpointWithApplicationPath('auth/login');

    log(url.toString());

    final loginRequest = loginRequestModel.LoginRequest(
      empId: userId,
      password: password,
      token: token,
      bearertoken: bearertoken,
      os: 'Android',
      version: appversion,
    );
    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    log(jsonEncode(loginRequest).toString());

    try {
      serviceSend("Login");
      return _handleRequest(
        onRequest:
            () => _client.post(
              url,
              body: jsonEncode(loginRequest),
              headers: headers,
            ),
        onResponse: (response) {
          cookie = updateCookie(response);
          // fullcookie = updateFullCookie(response);

          return loginResponseFromJson(response.body);
        },
      );
    } catch (e) {
      serviceSendError("Login");
      rethrow;
    }
  }

  Future<http.Response> OrderService({
    required pagesize,
    required currentpage,
    required token,
    required role,
    required status,
  }) async {
    Uri urlorder;
    log("${pagesize.toString()}-------------------------------------");

    log("${currentpage.toString()}........................");

    if (status == "all") {
      urlorder = Uri.parse(
        _endpointWithApplicationPathString(
          'pickerDriverOrdersItems.php?page_size=${pagesize}&current_page=${currentpage}',
        ),
      );
    } else {
      urlorder = Uri.parse(
        _endpointWithApplicationPathString(
          'pickerDriverOrdersItems.php?page_size=${pagesize}&current_page=${currentpage}',
        ),
      );
    }

    log("-------------------------------------");

    log("${urlorder}");

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };
    log("${DateTime.now()}");
    try {
      serviceSend("order send");
      return _handleRequest(
        onRequest: () => _client.get(urlorder, headers: headers),
        onResponse: (responce) {
          log("${DateTime.now()}");

          return responce;
        },
      );
    } catch (e) {
      serviceSend("Order Send Error");
      rethrow;
    }
  }

  Future<http.Response> orderItemStatusUpdateService({
    required Map<String, dynamic> body,
    required token,
  }) {
    //
    // Uri url = Uri.parse(
    //   'https://pickerdriver.testuatah.com/v1/api/qatar/updateOrderItemV1.php',
    // );
    //
    //

    final url = _endpointWithApplicationPath('picker/orders/item/status');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token',
    };
    log('order items status ${body.toString()}');
    try {
      serviceSend("update item status service send");
      return _handleRequest(
        onRequest:
            () => _client.patch(url, body: jsonEncode(body), headers: headers),
        onResponse: (response) {
          log('order items status ${DateTime.now().toString()}');

          return response;
        },
      );
    } catch (e) {
      serviceSendError("update items status service Error $e");
      rethrow;
    }
  }

  Future<http.Response> OrderItemsService({
    required String orderid,
    required token,
  }) {
    //
    Uri url = Uri.parse(
      _endpointWithApplicationPathString('pdOrdersItemsV1.php'),
    );
    //
    //

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> body = {'suborderId': orderid};
    log('${url}');

    log(body.toString());
    try {
      serviceSend("order items service send");
      return _handleRequest(
        onRequest:
            () => _client.put(url, body: jsonEncode(body), headers: headers),
        onResponse: (response) {
          log('order items ${DateTime.now().toString()}');

          return response;
        },
      );
    } catch (e) {
      serviceSendError("Order items service Error");
      rethrow;
    }
  }

  Future<http.Response> updatemainorderstatNew({
    required String preparationId,
    required String orderStatus,
    required String comment,
    String? orderNumber,
    required String token,
  }) {
    // Uri url = Uri.parse(_endpointWithApplicationCustomPath(
    //     'custom-api/api/qatar/updateSubOrder.php'));

    Uri url = _endpointWithApplicationPath('picker/orders/status');

    final Map<String, dynamic> body = {
      "preparation_id": preparationId,
      "status": orderStatus,
      "comment": comment,
      "order_number": orderNumber,
    };

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token',
    };

    // print(url);

    log(url.toString());

    log(body.toString());

    log(DateTime.now().toString());

    try {
      serviceSend("update main order stat");
      return _handleRequest(
        onRequest:
            () => _client.patch(url, body: jsonEncode(body), headers: headers),
        onResponse: (response) {
          log(DateTime.now().toString());

          return response;
        },
      );
    } catch (e) {
      serviceSendError("Order Error");
      rethrow;
    }
  }

  Future<http.Response> updatemainorderstat({
    required String orderid,
    required String order_status,
    required String comment,
    required String userId,
    required String latitude,
    required String longitude,
    String? grandTotal,
    String? dueAmount,
    String? dispatchMethod,
    String? paymentMethod,
  }) {
    // Uri url = Uri.parse(_endpointWithApplicationCustomPath(
    //     'custom-api/api/qatar/updateSubOrder.php'));

    Uri url = Uri.parse(
      'https://pickerdriver.testuatah.com/v1/api/qatar/updateSubOrderV1.php',
    );

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
    };

    if (dispatchMethod != null) {
      switch (dispatchMethod) {
        case 'driver':
          dispatchMethod = 'rafeeq';
          break;
        case 'rider':
          dispatchMethod = 'rider';
          break;
        default:
          dispatchMethod = 'normal';
      }
    }

    final Map<String, dynamic> body = {
      "order_id": orderid,
      "order_status": order_status,
      "comment": comment,
      "user_id": userId,
      "latitude": latitude,
      "longitude": longitude,
      "grand_total": grandTotal,
      "due_amount": dueAmount,
      "driver_type": dispatchMethod,
      "payment_method": paymentMethod,
    };

    // print(url);

    log(body.toString());

    log(DateTime.now().toString());

    // throw Exception("Order Error");

    try {
      serviceSend("update main order stat");
      return _handleRequest(
        onRequest:
            () => _client.put(url, body: jsonEncode(body), headers: headers),
        onResponse: (response) {
          log(DateTime.now().toString());

          return response;
        },
      );
      // return http.Response('success', 200);
    } catch (e) {
      serviceSendError("Order Error");
      rethrow;
    }
  }

  Future uploadDocumentService(
    Uint8List imagebytes,
    Uint8List imagebytesdSign,
    Uint8List imagebytesqId,
    String orderid,
    int driverid,
  ) async {
    final Map<String, String> headers = {"Content-Type": "multipart/form-data"};

    Uri url = Uri.parse(
      _endpointWithApplicationPathString('delivery_verification.php'),
    );

    try {
      var request = await http.MultipartRequest('POST', url);

      final httpcSign = await http.MultipartFile.fromBytes(
        'customer_signature',
        imagebytes,
        filename: 'customersign-${orderid.toString()}.jpg',
      );

      final httpdSign = await http.MultipartFile.fromBytes(
        'driver_signature',
        imagebytesdSign,
        filename: 'driversign-${orderid.toString()}.jpg',
      );

      final httpqId = await http.MultipartFile.fromBytes(
        'document',
        imagebytesqId,
        filename: 'qId-${orderid.toString()}.jpg',
      );

      request.files.add(httpcSign);

      request.files.add(httpdSign);

      request.files.add(httpqId);

      request.fields['order_id'] = orderid.toString();

      request.fields['driver_id'] = driverid.toString();

      // print(driverid);

      final response = await request.send();

      String responsebody = await response.stream.bytesToString();

      // print(responsebody);

      log(responsebody);

      return response.statusCode;
    } catch (e) {
      log(e.toString());
      return "500";
    }
  }

  Future<http.Response> getsimilarProducts({required String product_id}) async {
    // final url = Uri.parse(
    //     'https://admin-qatar.testuatah.com/rest/V1/ahmarket-recommendation/related-product/' +
    //         product_id);

    final url =
        '${productUrl}ahmarket-recommendation/related-product/${product_id}';

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer 8jki6ynymuxwu6empi53bk0s43n7c6vi',
    };

    serviceSend("get similiar products request");

    serviceSend(url.toString());

    return _handleRequest(
      onRequest: () => _client.get(Uri.parse(url), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> generalProductService({
    required String endpoint,
    required String token,
  }) async {
    log("endpoint.........${endpoint}");

    // final url = Uri.parse(
    //     'https://admin-qatar.testuatah.com/custom-api/api/qatar/getProductdata_new.php?sku=' +
    //         endpoint.trim());

    final url = _endpointWithApplicationPathString(
      'getProductdata_new.php?sku=${endpoint.trim()}',
    );

    log(url.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    return _handleRequest(
      onRequest: () => _client.get(Uri.parse(url), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getProductService({
    required String endpoint,
    required String token,
  }) async {
    log("endpoint.........${endpoint}");

    // final url = Uri.parse(
    //     'https://admin-qatar.testuatah.com/custom-api/api/qatar/getProductdata_new.php?sku=' +
    //         endpoint.trim());

    final url = Uri.parse(
      'https://www.ansargallery.com/rest/V1/products/${endpoint}',
    );

    log(url.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> updateUserStat({
    required int userid,
    required int status,
  }) async {
    Uri url = Uri.parse(
      _endpointWithApplicationPathString('pd_online_status.php'),
    );

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
    };

    final Map<String, dynamic> body = {
      "user_id": userid,
      "online_status": status,
    };

    try {
      serviceSend("update user stat");
      return _handleRequest(
        onRequest:
            () => _client.put(url, body: jsonEncode(body), headers: headers),
        onResponse: (response) {
          log(DateTime.now().toString());

          return response;
        },
      );
    } catch (e) {
      serviceSendError("status update Error..");
      rethrow;
    }
  }

  Future rescheduleRequest({
    required String orderid,
    required String deliverydate,
    required int userid,
    required String timerange,
    required bool candeliver,
  }) {
    final url = _endpointWithApplicationPath('/rescheduleDelivery.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> data = {
      "order_id": orderid,
      "user_id": userid,
      "delivery_date": deliverydate,
      "time_range": timerange,
      "can_deliver": candeliver ? 1 : 0,
    };

    log(data.toString());

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(data), headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future rescheduleRequestNOL({
    required String orderid,
    required String deliverydate,
    required String comment,
    required bool candeliver,
    required int userid,
  }) async {
    final url = _endpointWithApplicationPath('/rescheduleDelivery.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> data = {
      "order_id": orderid,
      "user_id": userid,
      "delivery_date": deliverydate,
      "can_deliver": candeliver ? 1 : 0,
      "comment": comment,
    };

    serviceSend("Reschedule Request");
    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(data), headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future<http.Response> getlocationdetails(
    String startlat,
    String endlat,
    String destlat,
    String destlong,
  ) async {
    serviceSend("Distence detsils");

    const google_api_key = "AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA";

    // print(
    //   "https://maps.googleapis.com/maps/api/directions/json?origin=${startlat}%2C${endlat}&destination=${destlat}%2C${destlong}&travelMode=transit&avoidHighways=false&avoidFerries=true&avoidTolls=false&key=${google_api_key}",
    // );
    return _handleRequest(
      onRequest:
          () => _client.get(
            Uri.parse(
              "https://maps.googleapis.com/maps/api/directions/json?origin=${startlat}%2C${endlat}&destination=${destlat}%2C${destlong}&travelMode=transit&avoidHighways=false&avoidFerries=true&avoidTolls=false&key=${google_api_key}",
            ),
          ),
      onResponse: (responce) {
        return responce;
      },
    );
  }

  Future<http.Response> updateDriverLocation({
    required int userId,
    required String latitude,
    required String longitude,
  }) async {
    final url = Uri.parse(
      'https://pickerdriver.testuatah.com/v1/api/qatar/pd_driverstatus.php',
    );

    log(url.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    serviceSend("User Distance Update");

    Map<String, dynamic> usermap = {
      "user_id": userId,
      "lat": latitude,
      "long": longitude,
    };

    log(usermap.toString());

    try {
      return _handleRequest(
        onRequest:
            () => _client.put(url, body: jsonEncode(usermap), headers: headers),
        onResponse: (response) {
          return response;
        },
      );
    } catch (e) {
      serviceSendError("User Distance Update Error");
      rethrow;
    }
  }

  Future<http.Response> OrderREportService({
    required String startDate,
    required String endDate,
    required token,
  }) {
    Uri url;

    // print("${startDate} <<<<<<<<<<<<<<<start data");
    // print("${endDate} <<<<<<<<<<<<<<<endDate data");
    // print("${token} <<<<<<<<<<<<<<<token data");

    if (startDate != "" && endDate == "") {
      url = Uri.parse(
        _endpointWithApplicationPathString(
          'getStatusHistoriesV1.php?startdate=$startDate',
        ),
      );
    } else {
      url = Uri.parse(
        _endpointWithApplicationPathString(
          'getStatusHistoriesV1.php?startdate=$startDate&enddate=$endDate',
        ),
      );
    }

    log(url.toString());

    final Map<String, String> headers = {
      "Content-Type": ContentTypes.applicationJson,
      'Authorization': 'Bearer $token',
    };

    serviceSend("Order Report Service");

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.StreamedResponse> uploadBillService(
    File bill,
    String ordernumber,
  ) async {
    final Map<String, String> headers = {"Content-Type": "multipart/form-data"};

    log(DateTime.now().toString() + ".....time started");

    Uri url = Uri.parse(_endpointWithApplicationPathString("upload-bill.php"));

    log(url.toString());

    Uint8List imagebytes = await bill.readAsBytes();
    var request = await http.MultipartRequest('POST', url);
    final httpimage = http.MultipartFile.fromBytes(
      'bill',
      imagebytes,
      filename: 'billimage.jpg',
    );
    request.files.add(httpimage);
    request.fields['order_number'] = ordernumber;
    final response = await request.send();
    log(DateTime.now().toString() + ".....time ended");

    return response;
  }

  Future<http.Response> getStatusHistoryData(String orderid) async {
    Uri url = Uri.parse(
      _endpointWithApplicationPathString('order-history.php?order_id=$orderid'),
    );

    log(url.toString());

    final Map<String, String> headers = {
      "Content-Type": ContentTypes.applicationCharset,
    };

    try {
      serviceSend("status history data send");
      return _handleRequest(
        onRequest: () => _client.get(url, headers: headers),
        onResponse: (response) {
          return response;
        },
      );
    } catch (e) {
      serviceSend("status history data error");
      rethrow;
    }
  }

  Future<http.Response> sendNotification({
    required String bearertoken,
    required String devicetoken,
    required String title,
    required String body,
  }) async {
    Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/ah-market-5ab28/messages:send',
    );

    final Map<String, String> headers = {
      "Authorization": "Bearer ${bearertoken}",
      "Content-Type": ContentTypes.applicationJson,
    };

    final Map<String, dynamic> data = {
      "message": {
        "token": "${devicetoken}",
        "data": {"message_id": "0001", "id": "1"},
        "notification": {"title": "${title}", "body": "${body}"},
        "android": {
          "notification": {
            "channel_id":
                "channel_id_5", // Ensure correct spelling for channel_id
          },
        },
      },
    };

    try {
      serviceSend("Send Notification");

      return _handleRequest(
        onRequest:
            () => _client.post(url, body: jsonEncode(data), headers: headers),
        onResponse: (response) {
          return response;
        },
      );
    } catch (e) {
      serviceSend("send notification data error");
      rethrow;
    }
  }

  Future<http.Response> updateSectionData({
    required UpdateSectionRequest updateSectionRequest,
    required String branch,
  }) async {
    // final url;

    // if (branch != "Q013") {
    //   url = _endpointWithApplicationPath('updateproductstatusbranch.php');
    // } else {
    //   url = _endpointWithApplicationPath('updateproductstatus.php');
    // }

    final url = _endpointWithApplicationPath('updateproductstatus.php');

    // print(url);

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    // print("section update service");

    log(updateSectionRequest.toJson().toString());

    log(branch);

    log(url.toString());

    return _handleRequest(
      onRequest:
          () => _client.post(
            url,
            body: jsonEncode(updateSectionRequest.toJson()),
            headers: headers,
          ),
      onResponse: (response) {
        log(DateTime.now().toString());
        return response;
      },
    );
  }

  Future<http.Response> driverRegisterService({
    required Map<String, dynamic> driverdata,
  }) async {
    final url = _endpointWithApplicationPath('driver-register.php');

    log(url.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    return _handleRequest(
      onRequest:
          () =>
              _client.post(url, headers: headers, body: jsonEncode(driverdata)),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getLastID() async {
    // Uri urlorder;
    final url = _endpointWithApplicationPath('get_last_Id.php');
    // log("${urlorder.path.toString()}-------------------------------------");

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    log(url.toString());

    try {
      serviceSend("last data get");
      return _handleRequest(
        onRequest: () => _client.get(url, headers: headers),
        onResponse: (response) {
          return response;
        },
      );
    } catch (e) {
      serviceSendError("last data Error");
      rethrow;
    }
  }

  Future checkavailabilitybarcode({required String sku}) async {
    final url = _endpointWithApplicationPath('/checkAvailabileBarcode.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> body = {"sku": sku};

    serviceSend("Check Barcode Availablity..!");

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future checkPromotionService({required String endpoint}) async {
    final url = Uri.parse(
      'https://pickerdriver.testuatah.com/v1/api/qatar/scan_barcode_percentage.php?barcode=$endpoint',
    );

    log(url.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future<http.Response> checkBarcodeDB({
    required String endpoint,
    required String productSku,
    required String action,
    required String token1,
  }) async {
    // print("${endpoint} endpoint");
    // print("${productSku} productSku");
    // print("${action} action");

    final Map<String, String> body = {
      "sku": endpoint,
      "ordersku": productSku,
      "action": action,
    };

    // final url = Uri.parse(
    //   'https://pickerdriver.testuatah.com/v1/api/qatar/getProductdata_newV2.php?sku=$endpoint&ordersku=$productSku&action=$action',
    // );

    // print(
    //   'https://pickerdriver.testuatah.com/v1/api/qatar/getProductdata_newV2.php?sku=$endpoint&ordersku=$productSku&action=$action',
    // );

    log("-------------------------------------");

    log(body.toString());

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token1',
    };

    final url = _endpointWithApplicationPath('picker/orders/check-sku');

    log(url.toString());

    return _handleRequest(
      onRequest:
          () => _client.post(url, headers: headers, body: jsonEncode(body)),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getCashierOrdersSearch({
    required String key,
    required String token,
  }) async {
    final url = _endpointWithApplicationPathString(
      'cashier/orders/search?key=$key',
    );

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    log(url.toString());

    serviceSend("search Cashier Orders...!");

    return _handleRequest(
      onRequest: () => _client.get(Uri.parse(url), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<String> getSectionData(
    String user,
    int catid,
    String categoryIds,
    String branchCode,
  ) async {
    // Uri urlorder;
    String url = _endpointWithApplicationPathSection(
      user,
      catid,
      categoryIds,
      branchCode,
    );
    // log("${urlorder.path.toString()}-------------------------------------");

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    // print(user);
    log(url.toString());

    try {
      serviceSend("section data send");
      return _handleRequest(
        onRequest: () => _client.get(Uri.parse(url), headers: headers),
        onResponse: (response) {
          return response.body;
        },
      );
    } catch (e) {
      serviceSendError("section data Error");
      rethrow;
    }
  }

  Future<String> getSectionDataCheckList({
    required String branchcode,
    required String userid,
    required String categoryIds,
  }) {
    final url = _endpointWithApplicationPath('/check_status.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> body = {
      "branchcode": branchcode,
      "user_id": userid,
    };

    serviceSend("Check Barcode Status Availablity..!");

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future<String> clearStockData({
    required String userid,
    required String branchcode,
  }) {
    final url = _endpointWithApplicationPath('/clear_stock_items.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> body = {
      "branch_code": branchcode,
      "user_id": userid,
    };

    serviceSend("Clear All Stock Data..!");

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response.body;
      },
    );
  }

  Future addtoproductlist({
    required List<Map<String, dynamic>> dynamiclist,
  }) async {
    final url = _endpointWithApplicationPath('/addSkuScanned.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> body = {"items": dynamiclist};

    serviceSend("add to product list service full");
    log(DateTime.now().toString());

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        log(DateTime.now().toString());
        return response;
      },
    );
  }

  Future<http.Response> updateBatchPickup({
    required List<int> itemids,
    required String userid,
    required String token1,
    required String status,
    required List<String> orderIds,
    required String itemSku,
    required String preparationId,
  }) async {
    final url = _endpointWithApplicationPath('picker/orders/item/statusbulk');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token1',
    };

    final Map<String, dynamic> body = {
      "itemIds": itemids,
      "picker_id": userid,
      "itemstatus": status,
      "order_id": orderIds,
      "sku": itemSku,
    };

    serviceSend("Update Barcode Log..!");

    log(body.toString());

    log(headers.toString());

    return _handleRequest(
      onRequest:
          () => _client.patch(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> updateOnlineStatus({
    required String userid,
    required String token1,
    required String status,
  }) async {
    final url = _endpointWithApplicationPath('picker/pickerstatus');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationJson,
      'Authorization': 'Bearer $token1',
    };

    final Map<String, dynamic> body = {
      "online_status": status,
      "user_id": userid,
    };

    serviceSend("Update Online Status..!");

    log(body.toString());

    log(headers.toString());

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> updateBarcodeLog({
    required orderid,
    required String sku,
    required String scanned_sku,
    required String user_id,
  }) async {
    final url = _endpointWithApplicationPath('/updateBarcode_log.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    final Map<String, dynamic> body = {
      "parent_id": orderid,
      "order_barcode": sku,
      "scanned_barcode": scanned_sku,
      "picker_id": user_id,
    };

    serviceSend("Update Barcode Log..!");

    return _handleRequest(
      onRequest:
          () => _client.post(url, body: jsonEncode(body), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getCompanyList() async {
    final url = _endpointWithApplicationPath('/get_driver_companies.php');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    serviceSend("get Company Data...!");

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getInfoData() async {
    final url = _endpointWithApplicationPath('/auth/infodata');

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
    };

    serviceSend("get Info Data...!");

    return _handleRequest(
      onRequest: () => _client.get(url, headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }

  Future<http.Response> getCashierOrders({
    required int page,
    required int limit,
    required String token,
  }) async {
    final url = _endpointWithApplicationPathString(
      'cashier/orders?page=$page&limit=$limit',
    );

    final Map<String, String> headers = {
      'Content-Type': ContentTypes.applicationCharset,
      'Authorization': 'Bearer $token',
    };

    log(url.toString());

    serviceSend("get Cashier Orders Data...!");

    return _handleRequest(
      onRequest: () => _client.get(Uri.parse(url), headers: headers),
      onResponse: (response) {
        return response;
      },
    );
  }
}

extension on PickerDriverApi {
  Uri _endpointWithApplicationPath(String path) {
    // print(baseUrl.toString());
    // print("okok");
    // print(baseUrl.replace(path: '${baseUrl.path}$applicationPath$path'));
    return baseUrl.replace(path: '${baseUrl.path}$applicationPath$path');
  }

  String _endpointWithApplicationPathString(String path) {
    String newpath = '${baseUrl}$applicationPath$path';
    return newpath;
  }

  String _endpointWithApplicationPathSection(
    String userid,
    int catid,
    String categoryIds,
    String branchCode,
  ) {
    String root =
        baseUrl.replace(path: '${baseUrl.path}$applicationPath').toString();
    // print(
    //   '${root}get_section_data.php?category_ids=${categoryIds}&branch=${branchCode}',
    // );
    return '${root}get_section_data.php?category_ids=${categoryIds}&branch=${branchCode}';
    // switch (userid) {
    //   case "ahqa_fish":
    //   case "fish_alkhor":
    //   case "fish_rawdah":
    //   case "fish_rayyan":
    //     return '${root}get_section_data.php?category_ids=761,762,764,763';
    //   case "ahqa_butch":
    //   case "alkhor_butch":
    //   case "rawdah_butch":
    //   case "rayyan_butch":
    //     if (catid != 0) {
    //       return '${root}get_section_data.php?category_ids=${catid.toString()}';
    //     } else {
    //       return '${root}get_section_data.php?category_ids=17';
    //     }
    //   case "ahqa_deli":
    //   case "alkhor_deli":
    //   case "rawdah_deli":
    //   case "rayyan_deli":
    //     return '${root}get_section_data.php?category_ids=793,782,781';
    //   case "ahqa_veg":
    //     return '${root}get_section_data.php?category_ids=10,9,11,744,1217,1225,1214,1215,1216,1207,1219,1226,1220,1230,1228,1231,1299';
    //   case "veg_rawdah":
    //     return '${mainbaseUrl}${applicationPath}getARProduceData.php?category_id=14&branch_code=Q015';
    //   case "veg_rayyan":
    //     log('${mainbaseUrl}');
    //     log(
    //       '${mainbaseUrl}${applicationPath}getARProduceData.php?category_id=14&branch_code=Q008',
    //     );
    //     return '${mainbaseUrl}${applicationPath}getARProduceData.php?category_id=14&branch_code=Q008';
    //   case "ah_grabgo":
    //     return '${mainbaseUrl}${applicationPath}get_section_data.php?category_ids=101';
    //   default:
    //     return '${root}get_section_data.php?category_ids=10,9,11,744,1217,1225,1215,1216,1207,1219,1226,1220,1230,1228,1231';
    // }
  }

  Future<T> _handleRequest<T>({
    required Future<http.Response> Function() onRequest,
    required T Function(http.Response) onResponse,
  }) async {
    if (!networkOnline) {
      throw NetworkException(
        "Oops, device is offline, please check your internet connection.",
      );
    }

    try {
      final response = await onRequest().timeout(
        timeoutDuration,
        onTimeout: () => throw TimeoutException("Request timed out"),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw NetworkException("Response is empty");
        }

        final baseResponse = BaseResponse.fromJson(response.body);
        if (baseResponse.errorCode == 1604) {
          throw NetworkException("Session timeout, please relogin");
        }

        return onResponse(response);
      } else {
        _logResponseError(response);
        return onResponse(
          response,
        ); // Optional: Handle non-200 status codes here
      }
    } on SocketException catch (e) {
      log("Socket Exception: $e", time: DateTime.now());
      throw NetworkException("Network error: Unable to reach server");
    } on TimeoutException catch (e) {
      log("Timeout Exception: $e", time: DateTime.now());
      throw NetworkException('Request took too long, please try again');
    } on ResponseFailure catch (e) {
      log("Response Failure: $e", time: DateTime.now());
      if (e.errorMessage == 'You are not logged in, please log back in') {
        throw e.errorMessage;
      }
      rethrow;
    } catch (e) {
      log("Unexpected Error: $e", time: DateTime.now());
      throw Exception(e.toString());
    }
  }

  void _logResponseError(http.Response response) {
    log("Response Error: ${response.statusCode}", time: DateTime.now());
    log("Response Body: ${response.body}");
  }

  Future<T> _handleHTTPRequest<T>({
    required Future<http.Response> Function() onRequest,
    required T Function(http.Response) onResponse,
  }) async {
    if (!networkOnline) {
      throw "Oops, device is offline, please check your internet connection.";
    } else {
      try {
        final response = await onRequest().timeout(
          timeoutDuration,
          onTimeout: () => throw TimeoutException("Timeout Exception"),
        );
        if (response.statusCode == 200) {
          if ((response.contentLength ?? 0) < 1) {
            throw "respose is empty";
          }
          return onResponse(response);
        } else {
          log("Network Response Error", time: DateTime.now());
          throw "Network error"; //"Oops, We are having some trouble connecting";
        }
      } on SocketException {
        log("Socket Exception", time: DateTime.now());
        throw "Network error"; //'We are having some trouble reaching the server';
      } on TimeoutException {
        log("Timeout Exception", time: DateTime.now());
        throw 'Its taking longer than usual, please try again';
      } on ResponseFailure catch (e) {
        log("Response Failure", time: DateTime.now());
        if (e.errorMessage == 'You are not logged in, please log back in') {
          throw e.errorMessage;
        }
        rethrow;
      } catch (e) {
        throw e.toString();
      }
    }
  }
}

String updateCookie(http.Response response) {
  String cookie = "";
  List<String> cookies = [];
  if (response.headers.containsKey('set-cookie')) {
    String rawCookie = response.headers['set-cookie'] ?? "";
    cookies = rawCookie.split("; ");
    for (var item in cookies) {
      item = item.replaceFirst("Secure,", "");
      if (item.startsWith("JSESSIONID=")) {
        cookie = item;
        break;
      }
    }
  }
  return cookie;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
