import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PaymentCollectionCubit extends Cubit<PaymentCollectionState> {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data = {};
  PaymentCollectionCubit({required this.serviceLocator, required this.data})
    : super(PaymentCollectionInitial()) {
    initializePayment();
  }

  Order? orderResponseItem;
  double totalAmount = 0;
  double cashAmount = 0;
  double cardAmount = 0;
  String paymentMethod = 'cash'; // 'cash', 'card', 'split'
  String orderPaymentMethod = 'cash';

  void initializePayment() {
    orderResponseItem = data['orderResponse'];
    if (orderResponseItem != null) {
      totalAmount =
          double.tryParse(orderResponseItem!.grandTotal?.toString() ?? '0') ??
          0;

      final normalizedMethod = _normalizePaymentMethod(
        orderResponseItem!.paymentMethod,
      );

      orderPaymentMethod = normalizedMethod;

      if (normalizedMethod == 'card') {
        cashAmount = 0;
        cardAmount = totalAmount;
      } else if (normalizedMethod == 'split') {
        cashAmount = 0;
        cardAmount = 0;
      } else {
        cashAmount = totalAmount;
        cardAmount = 0;
      }

      paymentMethod = normalizedMethod;

      emit(
        PaymentCollectionLoaded(
          totalAmount: totalAmount,
          cashAmount: cashAmount,
          cardAmount: cardAmount,
          paymentMethod: paymentMethod,
          orderPaymentMethod: orderPaymentMethod,
          balanceRemaining: totalAmount - cashAmount - cardAmount,
        ),
      );
    }
  }

  String _normalizePaymentMethod(String? method) {
    final normalized = (method ?? '').trim().toLowerCase();
    if (normalized.contains('card')) {
      return 'card';
    }
    if (normalized.contains('split')) {
      return 'split';
    }
    return 'cash';
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    double remainingBalance = totalAmount;

    if (method == 'cash') {
      cashAmount = totalAmount;
      cardAmount = 0;
      remainingBalance = 0;
    } else if (method == 'card') {
      cashAmount = 0;
      cardAmount = totalAmount;
      remainingBalance = 0;
    } else if (method == 'split') {
      if (orderPaymentMethod == 'card') {
        cashAmount = 0;
        cardAmount = totalAmount;
      } else if (orderPaymentMethod == 'cash') {
        cashAmount = totalAmount;
        cardAmount = 0;
      } else {
        cashAmount = 0;
        cardAmount = 0;
      }
      remainingBalance = totalAmount - cashAmount - cardAmount;
    }

    _emitLoaded(remainingBalance);
  }

  void updateCashAmount(double amount) {
    if (amount < 0) amount = 0;
    if (amount > totalAmount) amount = totalAmount;

    if (paymentMethod == 'split') {
      cashAmount = amount;
      cardAmount = totalAmount - amount;
    } else {
      cashAmount = amount;
      cardAmount = totalAmount - amount;

      if (cardAmount == 0) {
        paymentMethod = 'cash';
      } else if (cashAmount == 0) {
        paymentMethod = 'card';
      } else {
        paymentMethod = 'split';
      }
    }

    double remainingBalance = (totalAmount - cashAmount - cardAmount).clamp(
      0.0,
      double.infinity,
    );
    _emitLoaded(remainingBalance);
  }

  void updateCardAmount(double amount) {
    if (amount < 0) amount = 0;
    if (amount > totalAmount) amount = totalAmount;

    if (paymentMethod == 'split') {
      cardAmount = amount;
      cashAmount = totalAmount - amount;
    } else {
      cardAmount = amount;
      cashAmount = totalAmount - amount;

      if (cashAmount == 0) {
        paymentMethod = 'card';
      } else if (cardAmount == 0) {
        paymentMethod = 'cash';
      } else {
        paymentMethod = 'split';
      }
    }

    double remainingBalance = (totalAmount - cashAmount - cardAmount).clamp(
      0.0,
      double.infinity,
    );
    _emitLoaded(remainingBalance);
  }

  void _emitLoaded(double remainingBalance) {
    if (state is PaymentCollectionLoaded) {
      emit(
        (state as PaymentCollectionLoaded).copyWith(
          cashAmount: cashAmount,
          cardAmount: cardAmount,
          paymentMethod: paymentMethod,
          orderPaymentMethod: orderPaymentMethod,
          balanceRemaining: remainingBalance,
        ),
      );
    }
  }

  bool _isTotalCollected() {
    return (cashAmount + cardAmount - totalAmount).abs() < 0.005;
  }

  void collectPayment(BuildContext context) {
    if (!_isTotalCollected()) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: 'Please collect the full amount',
        ),
      );
      return;
    }

    // emit(PaymentCollectionInProgress());

    // Future.delayed(Duration(seconds: 2), () {
    //   emit(PaymentCollectionSuccess());
    // });
  }
}
