import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_cubit.dart';
import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrdersPage extends StatefulWidget {
  const CashierOrdersPage({super.key});

  @override
  State<CashierOrdersPage> createState() => _CashierOrdersPageState();
}

class _CashierOrdersPageState extends State<CashierOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<CashierOrdersPageCubit>().loadMore();
      }
    });
    // Rebuild to toggle clear icon visibility
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final orderId = _searchController.text.trim();
    if (orderId.isEmpty) {
      showSnackBar(
        context: context,
        snackBar: showWaringDialogue(errorMessage: 'Please enter an Order ID'),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<CashierOrdersPageCubit>().searchOrders(orderId);
  }

  void _onScan() {
    // Open existing scanner page (reused from profile page logic)
    final data = {"selected": 0};
    // context.gNavigationService.openNewScannerPage2(context, data);
  }

  void _onReset() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    context.read<CashierOrdersPageCubit>().refresh();
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
          IconButton(
            tooltip: 'Reset',
            onPressed: _onReset,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: BlocBuilder<CashierOrdersPageCubit, CashierOrdersPageState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (ctx, constraints) {
              final width = constraints.maxWidth;
              final isTablet = width >= 900;
              final maxWidth = isTablet ? 1100.0 : 640.0;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
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
                                      tooltip: 'Clear & Reset',
                                      onPressed: _onReset,
                                      icon: const Icon(Icons.close),
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
                        Expanded(
                          child: Builder(
                            builder: (_) {
                              if (state is CashierOrdersPageStateLoading ||
                                  state is CashierOrdersPageStateInitial) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (state is CashierOrdersPageStateError) {
                                return Center(
                                  child: Text(
                                    state.message,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyM_SemiBold,
                                      color: FontColor.FontPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              final success =
                                  state as CashierOrdersPageStateSuccess;
                              final List<Datum> items =
                                  success.cashierOrders.data;

                              if (items.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No orders found',
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyM_SemiBold,
                                      color: FontColor.FontSecondary,
                                    ),
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh:
                                    () =>
                                        context
                                            .read<CashierOrdersPageCubit>()
                                            .refresh(),
                                child:
                                    isTablet
                                        ? GridView.builder(
                                          controller: _scrollController,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                                childAspectRatio: 3.8,
                                              ),
                                          itemCount:
                                              items.length +
                                              (success.isLoadingMore ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index >= items.length) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            final order = items[index];
                                            return CashierOrderListItem(
                                              order: order,
                                            );
                                          },
                                        )
                                        : ListView.separated(
                                          controller: _scrollController,
                                          itemCount:
                                              items.length +
                                              (success.isLoadingMore ? 1 : 0),
                                          separatorBuilder:
                                              (_, __) =>
                                                  const SizedBox(height: 6),
                                          itemBuilder: (context, index) {
                                            if (index >= items.length) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 16.0,
                                                ),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }
                                            final order = items[index];
                                            return CashierOrderListItem(
                                              order: order,
                                            );
                                          },
                                        ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CashierOrderListItem extends StatelessWidget {
  final Datum order;
  const CashierOrderListItem({super.key, required this.order});

  String _formatDate(DateTime dt) {
    // Simple human-readable date/time
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = customColors();
    final titleStyle = customTextStyle(
      fontStyle: FontStyle.BodyM_Bold,
      color: FontColor.FontPrimary,
    );
    final subtitleStyle = customTextStyle(
      fontStyle: FontStyle.BodyS_Regular,
      color: FontColor.FontSecondary,
    );
    final amountStyle = customTextStyle(
      fontStyle: FontStyle.BodyM_Bold,
      color: FontColor.FontPrimary,
    );

    final String name = [
      order.firstname,
      order.lastname,
    ].where((e) => (e ?? '').trim().isNotEmpty).join(' ');

    final String dateText = _formatDate(order.deliveryFrom);
    final String timeRange = (order.timerange ?? '').toString();

    return Card(
      color: colors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: navigate to order details when available
          context.gNavigationService.openCashierOrderInnerPage(
            context,
            arg: {"order": order},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading status chip-like container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(order.orderStatus.toString()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getStatus(order.orderStatus.toString()),
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: subgroup identifier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.subgroupIdentifier}',
                            style: titleStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          double.parse(order.grandTotal).toStringAsFixed(2),
                          style: amountStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Customer name and postcode
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (name.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Text(name, style: subtitleStyle),
                            ],
                          ),
                        if ((order.postcode ?? '').isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 4),
                              Text(order.postcode!, style: subtitleStyle),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Delivery from and time range
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            timeRange.isNotEmpty
                                ? '$dateText  |  $timeRange'
                                : dateText,
                            style: subtitleStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
