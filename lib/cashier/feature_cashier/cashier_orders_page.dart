import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_cubit.dart';
import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrdersPage extends StatefulWidget {
  const CashierOrdersPage({super.key});

  @override
  State<CashierOrdersPage> createState() => _CashierOrdersPageState();
}

class _CashierOrdersPageState extends State<CashierOrdersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final orderId = _searchController.text.trim();
    if (orderId.isEmpty) {
      // If search is empty, reload all orders
      context.read<CashierOrdersPageCubit>().loadOrders();
      return;
    }

    // Search for specific order
    context.read<CashierOrdersPageCubit>().searchcashierOrders(orderId);
  }

  void _onScan() {
    // Open existing scanner page (reused from profile page logic)
    final data = {"selected": 0};
    context.gNavigationService.openNewScannerPage2(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final username = UserController.userController.profile.name;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: customColors().backgroundPrimary,
        title: Text(
          'Hi, $username',
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.assignment_ind),
          //   onPressed:
          //       () =>
          //           context.read<CashierOrdersPageCubit>().loadAssignedOrders(),
          //   tooltip: 'My Assigned Orders',
          // ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    context.read<CashierOrdersPageCubit>().loadAssignedOrders(),
            tooltip: 'All Orders',
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              // Simple and reliable logout - navigate to splash and clear all routes
              await PreferenceUtils.clear();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/splash', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: BlocBuilder<CashierOrdersPageCubit, CashierOrdersPageState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Order',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Enter Order ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<CashierOrdersPageCubit>()
                                    .loadOrders();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onSearch,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onScan,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan Barcode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildOrderList(state)),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed:
      //       () => context.read<CashierOrdersPageCubit>().loadAssignedOrders(),
      //   icon: const Icon(Icons.assignment_ind),
      //   label: const Text('My Orders'),
      //   backgroundColor: customColors().green4,
      //   tooltip: 'View my assigned orders',
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildOrderList(CashierOrdersPageState state) {
    if (state is CashierOrdersPageStateLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CashierOrdersPageStateError) {
      return Center(
        child: Text(
          state.message,
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_Regular,
            color: FontColor.Warning,
          ),
        ),
      );
    } else if (state is CashierOrdersPageStateSuccess) {
      final orders = state.cashierOrders.data;
      if (orders.isEmpty) {
        return Center(
          child: Text(
            'No orders found',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          context.read<CashierOrdersPageCubit>().loadOrders();
        },
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderTile(order: order);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class OrderTile extends StatelessWidget {
  final Datum order;

  OrderTile({Key? key, required this.order}) : super(key: key);

  bool _canNavigateToOrder() {
    return order.orderStatus.toLowerCase() == 'start_punching';
  }

  void _handleSwipeToStart(BuildContext context) {
    if (order.orderStatus.toLowerCase() != 'start_punching') {
      context.read<CashierOrdersPageCubit>().updateOrderStatus(
        orderId: order.subgroupIdentifier,
        status: 'start_punching',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(order.subgroupIdentifier),
        direction:
            order.orderStatus.toLowerCase() == 'start_punching'
                ? DismissDirection.none
                : DismissDirection.startToEnd,
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Swipe to Start Punching',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _handleSwipeToStart(context);
            return false; // Don't actually dismiss, just update status
          }
          return false;
        },
        child: InkWell(
          onTap: () {
            if (_canNavigateToOrder()) {
              context.gNavigationService.openCashierOrderInnerPage(
                context,
                arg: {'order': order},
              );
            } else {
              // Show message that user needs to swipe first
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please swipe right to start punching before accessing order details',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Got it',
                    textColor: Colors.white,
                    onPressed: () {
                      // Check if the context is still valid before using it
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }
                    },
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.subgroupIdentifier}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${order.firstname ?? 'N/A'}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: ${order.orderAmount ?? '0.00'}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_SemiBold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delivery Date: ${getdateformatted(order.deliveryFrom!)}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                gettimeformatted(order) != ''
                    ? Text(
                      'Time: ${gettimeformatted(order)}',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    )
                    : const SizedBox.shrink(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        getDriverTypeWidget(
                          order.driverType!,
                          getDriverType(order.driverType!),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          order.tracker_id?.toString() ?? '',
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ],
                    ),
                    order.isWhatsappOrder == 1
                        ? const Icon(Icons.chat_bubble)
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(order.orderStatus),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            getStatus(order.orderStatus),
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_SemiBold,
                              color: FontColor.White,
                            ),
                          ),
                        ),
                        if (order.orderStatus.toLowerCase() !=
                            'start_punching') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Swipe to start',
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyS_SemiBold,
                                    color: FontColor.White,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (order.statusHistory != null &&
                            DateUtils.isSameDay(
                              order.statusHistory!.createdAt,
                              DateTime.now(),
                            )) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: customColors().islandAqua,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ready to Dispatch',
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyS_Bold,
                                color: FontColor.White,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // final String deliveryDateText = getdateformatted(order.deliveryFrom);
  String gettimeformatted(Datum order) {
    return (() {
      if (order.timerange == null) {
        return '';
      }
      final tr = (order.timerange ?? '').toString().trim();
      if (tr.isNotEmpty) return tr;
      final from = order.deliveryFrom;
      final to = order.deliveryTo;
      final tf = DateFormat('hh:mm a');
      try {
        if (to != null) {
          final fromStr = tf.format(from!);
          final toStr = tf.format(to);
          if (fromStr != toStr) return '$fromStr - $toStr';
          return fromStr;
        }
        return tf.format(from!);
      } catch (_) {
        return null;
      }
    })().toString();
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'complete':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'end_picking':
        return Colors.lightBlue;
      case 'ready_to_dispatch':
        return Colors.lightGreen;
      case 'start_punching':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

String getDriverType(String driverType) {
  switch (driverType.toLowerCase()) {
    case 'rafeeq':
    case 'rider':
      return 'Rafeeq';
    case 'rad':
      return 'RAD';
    case 'shipbee':
      return 'Shipbee';
    default:
      return 'Ansar';
  }
}
