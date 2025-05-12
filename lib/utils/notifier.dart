import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:event_bus/event_bus.dart';

// Create a global event bus instance
EventBus eventBus = EventBus();

class DataChangedEvent {
  final String newData;
  DataChangedEvent(this.newData);

  updatePriceData(String orderid, String price) {
    if (UserController.userController.orderdata.containsKey(orderid)) {
      UserController.userController.orderdata[orderid] =
          UserController.userController.orderdata[orderid] +
          double.parse(price);
    } else {
      UserController.userController.orderdata.addAll({orderid: price});
    }
  }
}
