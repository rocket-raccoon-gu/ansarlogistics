import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_cubit.dart';
import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      showSnackBar(
        context: context,
        snackBar: showWaringDialogue(errorMessage: 'Please enter an Order ID'),
      );
      return;
    }

    // TODO: Fetch order details by ID and navigate to details page.
    showSnackBar(
      context: context,
      snackBar: showWaringDialogue(
        errorMessage: 'Search by Order ID is not implemented yet',
      ),
    );
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
                  child: Center(
                    child: Text(
                      'Search or scan an order to view details',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_SemiBold,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
