import 'dart:convert';

import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:event_bus/event_bus.dart';

// Create a global event bus instance
EventBus eventBus = EventBus();

class DataChangedEvent {
  final String newData;
  DataChangedEvent(this.newData);

  updatePriceData(String orderid, String price) async {
    try {
      // print("🔄 Updating price data...");
      // print("➡️ Order ID: $orderid");
      // print("➡️ New Price: $price");

      if (UserController.userController.orderdata.containsKey(orderid)) {
        // print("📝 Existing order found. Adding price.");
        UserController.userController.orderdata[orderid] =
            UserController.userController.orderdata[orderid]! +
            double.parse(price);
      } else {
        // print("🆕 New order. Initializing price.");
        UserController.userController.orderdata.addAll({
          orderid: double.parse(price),
        });
      }

      String jsonString = json.encode(UserController.userController.orderdata);
      // print("📦 Encoded order data: $jsonString");

      await PreferenceUtils.storeDataToShared('orderdata', jsonString);
      // print("✅ Order data stored in shared preferences.");
    } catch (e) {
      // print("🔥 Error updating price data: $e");
      throw e;
    }
  }
}

Future<void> saveOrderDataToPrefs() async {
  // print("💾 Saving order data to shared preferences...");
  String jsonString = json.encode(UserController.userController.orderdata);
  // print("📦 Encoded order data: $jsonString");
  await PreferenceUtils.storeDataToShared('orderdata', jsonString);
  // print("✅ Order data saved successfully.");
}
