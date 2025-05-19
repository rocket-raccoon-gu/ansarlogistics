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
      if (UserController.userController.orderdata.containsKey(orderid)) {
        UserController.userController.orderdata[orderid] =
            UserController.userController.orderdata[orderid]! +
            double.parse(price);
      } else {
        UserController.userController.orderdata.addAll({
          orderid: double.parse(price),
        });
      }

      String jsonString = json.encode(UserController.userController.orderdata);
      await PreferenceUtils.storeDataToShared('orderdata', jsonString);
    } catch (e) {
      throw e;
    }
  }
}

Future<void> saveOrderDataToPrefs() async {
  String jsonString = json.encode(UserController.userController.orderdata);
  await PreferenceUtils.storeDataToShared('orderdata', jsonString);
}
