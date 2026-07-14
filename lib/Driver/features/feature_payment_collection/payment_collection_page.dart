import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PaymentCollectionPage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  Map<String, dynamic>? data;
  PaymentCollectionPage({
    super.key,
    required this.serviceLocator,
    required this.data,
  });

  @override
  State<PaymentCollectionPage> createState() => _PaymentCollectionPageState();
}

class _PaymentCollectionPageState extends State<PaymentCollectionPage> {
  Order? orderResponseItem;
  late TextEditingController _cashController;
  late TextEditingController _cardController;
  late FocusNode _cashFocusNode;
  late FocusNode _cardFocusNode;

  @override
  void initState() {
    super.initState();
    orderResponseItem = widget.data!['orderResponse'];
    _cashController = TextEditingController();
    _cardController = TextEditingController();
    _cashFocusNode = FocusNode();
    _cardFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _cardController.dispose();
    _cashFocusNode.dispose();
    _cardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: customColors().primary,
        title: Text(
          'Payment Collection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: BlocBuilder<PaymentCollectionCubit, PaymentCollectionState>(
        builder: (context, state) {
          if (state is PaymentCollectionSuccess) {
            return _buildSuccessScreen(context);
          }

          if (state is PaymentCollectionError) {
            return _buildErrorScreen(context, state.message);
          }

          if (state is PaymentCollectionLoaded) {
            _syncControllers(state);
            return _buildPaymentForm(context, state);
          }

          return Center(
            child: CircularProgressIndicator(color: customColors().primary),
          );
        },
      ),
    );
  }

  void _syncControllers(PaymentCollectionLoaded state) {
    final cashText = state.cashAmount.toStringAsFixed(2);
    final cardText = state.cardAmount.toStringAsFixed(2);

    if (!_cashFocusNode.hasFocus && _cashController.text != cashText) {
      _cashController.text = cashText;
      _cashController.selection = TextSelection.collapsed(
        offset: cashText.length,
      );
    }

    if (!_cardFocusNode.hasFocus && _cardController.text != cardText) {
      _cardController.text = cardText;
      _cardController.selection = TextSelection.collapsed(
        offset: cardText.length,
      );
    }
  }

  Widget _buildPaymentForm(
    BuildContext context,
    PaymentCollectionLoaded state,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Card
            _buildTotalAmountCard(state),
            SizedBox(height: 24),

            // Payment Method Selection
            _buildPaymentMethodSection(context, state),
            SizedBox(height: 24),

            if (state.paymentMethod == 'cash' || state.paymentMethod == 'split')
              _buildAmountInputField(
                context,
                'Cash Amount',
                _cashController,
                state.totalAmount,
                true,
                (value) {
                  context.read<PaymentCollectionCubit>().updateCashAmount(
                    double.tryParse(value) ?? 0,
                  );
                },
                focusNode: _cashFocusNode,
              ),
            if (state.paymentMethod == 'cash' || state.paymentMethod == 'split')
              SizedBox(height: 16),

            if (state.paymentMethod == 'card' || state.paymentMethod == 'split')
              _buildAmountInputField(
                context,
                'Card Amount',
                _cardController,
                state.totalAmount,
                true,
                (value) {
                  context.read<PaymentCollectionCubit>().updateCardAmount(
                    double.tryParse(value) ?? 0,
                  );
                },
                focusNode: _cardFocusNode,
              ),
            if (state.paymentMethod == 'card' || state.paymentMethod == 'split')
              SizedBox(height: 16),
            SizedBox(height: 24),

            // Balance Remaining
            if (state.balanceRemaining > 0) _buildBalanceRemaining(state),
            SizedBox(height: 32),

            // Collection Summary
            _buildCollectionSummary(state),
            SizedBox(height: 32),

            // Update Payment Button
            _buildUpdateButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard(PaymentCollectionLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customColors().primary,
            customColors().primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: customColors().primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount to Collect',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '${state.totalAmount.toStringAsFixed(2)} QAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    PaymentCollectionLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: customColors().fontPrimary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton(
                context,
                'Cash on Delivery',
                Icons.money,
                state.paymentMethod == 'cash',
                () => context
                    .read<PaymentCollectionCubit>()
                    .updatePaymentMethod('cash'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildPaymentMethodButton(
                context,
                'Card on Delivery',
                Icons.credit_card,
                state.paymentMethod == 'card',
                () => context
                    .read<PaymentCollectionCubit>()
                    .updatePaymentMethod('card'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton(
                context,
                'Split Payment',
                Icons.layers,
                state.paymentMethod == 'split',
                () => context
                    .read<PaymentCollectionCubit>()
                    .updatePaymentMethod('split'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? customColors().primary : Colors.white,
          border: Border.all(
            color: customColors().primary,
            width: isSelected ? 0 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: customColors().primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : customColors().primary,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : customColors().fontPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputField(
    BuildContext context,
    String label,
    TextEditingController controller,
    double maxAmount,
    bool isEditable,
    Function(String) onChanged, {
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: customColors().fontPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          enabled: isEditable,
          onChanged: isEditable ? onChanged : null,
          readOnly: !isEditable,
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '₹ ',
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () => _showPaymentMethodModal(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: customColors().primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: customColors().primary.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: customColors().primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: customColors().primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: customColors().fontPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRemaining(PaymentCollectionLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info, color: Colors.orange, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance to Collect',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${state.balanceRemaining.toStringAsFixed(2)} QAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSummary(PaymentCollectionLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColors().primary.withOpacity(0.05),
        border: Border.all(color: customColors().primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: customColors().fontPrimary,
            ),
          ),
          SizedBox(height: 12),
          _buildSummaryRow('Cash', state.cashAmount),
          SizedBox(height: 8),
          _buildSummaryRow('Card', state.cardAmount),
          Divider(color: customColors().primary.withOpacity(0.2), height: 16),
          _buildSummaryRow(
            'Total',
            state.totalAmount,
            isBold: true,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color:
                isTotal ? customColors().primary : customColors().fontPrimary,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} QAR',
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color:
                isTotal ? customColors().primary : customColors().fontPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(
    BuildContext context,
    PaymentCollectionLoaded state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (state is PaymentCollectionInProgress)
                ? null
                : () => _showConfirmPaymentDialog(context, state),
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors().primary,
          disabledBackgroundColor: customColors().primary.withOpacity(0.5),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child:
            (state is PaymentCollectionInProgress)
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  'Update Payment Collection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  void _showConfirmPaymentDialog(
    BuildContext context,
    PaymentCollectionLoaded state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Confirm Payment Collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please verify the amounts before confirming.'),
              SizedBox(height: 16),
              _buildDialogSummaryRow('Total', state.totalAmount),
              SizedBox(height: 8),
              _buildDialogSummaryRow('Cash', state.cashAmount),
              SizedBox(height: 8),
              _buildDialogSummaryRow('Card', state.cardAmount),
              SizedBox(height: 8),
              _buildDialogSummaryRow('Balance', state.balanceRemaining),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PaymentCollectionCubit>().collectPayment(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customColors().secretGarden,
              ),
              child: Text(
                'Confirm',
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.White,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        Text('${amount.toStringAsFixed(2)} QAR'),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 80, color: Colors.green),
          ),
          SizedBox(height: 20),
          Text(
            'Payment Collected Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: customColors().fontPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'The payment has been recorded and updated.',
            textAlign: TextAlign.center,
            style: TextStyle(color: customColors().fontSecondary, fontSize: 14),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back),
            label: Text('Back to Orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors().primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 80, color: Colors.red),
          ),
          SizedBox(height: 20),
          Text(
            'Error',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: customColors().fontSecondary, fontSize: 14),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<PaymentCollectionCubit>().initializePayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors().primary,
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodModal(BuildContext context) {
    // Capture the cubit before showing modal to avoid provider scope issues
    final cubit = context.read<PaymentCollectionCubit>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: customColors().fontPrimary,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.money, color: customColors().primary),
                title: Text('Cash on Delivery'),
                onTap: () {
                  cubit.updatePaymentMethod('cash');
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: customColors().primary),
                title: Text('Card on Delivery'),
                onTap: () {
                  cubit.updatePaymentMethod('card');
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: Icon(Icons.layers, color: customColors().primary),
                title: Text('Split Payment (Cash + Card)'),
                onTap: () {
                  cubit.updatePaymentMethod('split');
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
