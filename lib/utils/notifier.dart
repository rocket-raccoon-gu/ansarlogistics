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

// Broadcast when an order item status is updated (e.g., to end_picking)
class ItemStatusUpdatedEvent {
  final String itemId;
  final String newStatus; // e.g., 'end_picking'
  final String? newPrice; // optional updated unit price as string
  final int? newQty; // optional picked qty (units)
  ItemStatusUpdatedEvent({
    required this.itemId,
    required this.newStatus,
    this.newPrice,
    this.newQty,
  });
}

Future<void> saveOrderDataToPrefs() async {
  String jsonString = json.encode(UserController.userController.orderdata);
  await PreferenceUtils.storeDataToShared('orderdata', jsonString);
}
