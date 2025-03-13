import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PostRepositories {
  final PostService postService;

  PostRepositories(this.postService);

  Future<List<Order>> fetchposts(int page, int pagecount, String status) async {
    final post = await postService.fetchpost(page, pagecount, status);
    UserController.userController.orderitems.addAll(post);
    return post;
  }

  // Future<List>
}
