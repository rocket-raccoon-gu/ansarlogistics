import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PostRepositories {
  final PostService postService;

  PostRepositories(this.postService);

  // Future<List<OrderNew>> fetchposts(int page, int pagecount, String status) async {
  //   final String statusToPass = status == 'all' ? '' : status;
  //   final post = await postService.fetchpost(page, pagecount, statusToPass);
  //   UserController.userController.orderitems.addAll(post);
  //   return post;
  // }

  // New: non-paginated orders + categories
  Future<OrdersNewResponse?> fetchOrdersNew() async {
    final resp = await postService.fetchOrdersNew();
    return resp;
  }
}
