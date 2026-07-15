import 'dart:convert';

import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

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
  String secondaryPaymentMethod = 'card';
  String secondaryPaymentAmount = '0.00';

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
      _syncSecondaryPaymentDetails();

      emit(
        PaymentCollectionLoaded(
          totalAmount: totalAmount,
          cashAmount: cashAmount,
          cardAmount: cardAmount,
          paymentMethod: paymentMethod,
          orderPaymentMethod: orderPaymentMethod,
          secondaryPaymentMethod: secondaryPaymentMethod,
          secondaryPaymentAmount: secondaryPaymentAmount,
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
      secondaryPaymentMethod = '';
      secondaryPaymentAmount = '';
    } else if (method == 'card') {
      cashAmount = 0;
      cardAmount = totalAmount;
      remainingBalance = 0;
      secondaryPaymentMethod = '';
      secondaryPaymentAmount = '';
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
      _syncSecondaryPaymentDetails();
    }

    _emitLoaded(remainingBalance);
  }

  void updateCashAmount(double amount) {
    if (amount < 0) amount = 0;
    if (amount > totalAmount) amount = totalAmount;

    if (paymentMethod == 'split') {
      cashAmount = amount;
      cardAmount = totalAmount - amount;
      _syncSecondaryPaymentDetails();
    } else {
      cashAmount = amount;
      cardAmount = totalAmount - amount;

      if (cardAmount == 0) {
        paymentMethod = 'cash';
        secondaryPaymentMethod = '';
        secondaryPaymentAmount = '';
      } else if (cashAmount == 0) {
        paymentMethod = 'card';
        secondaryPaymentMethod = '';
        secondaryPaymentAmount = '';
      } else {
        paymentMethod = 'split';
        _syncSecondaryPaymentDetails();
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
      _syncSecondaryPaymentDetails();
    } else {
      cardAmount = amount;
      cashAmount = totalAmount - amount;

      if (cashAmount == 0) {
        paymentMethod = 'card';
        secondaryPaymentMethod = '';
        secondaryPaymentAmount = '';
      } else if (cardAmount == 0) {
        paymentMethod = 'cash';
        secondaryPaymentMethod = '';
        secondaryPaymentAmount = '';
      } else {
        paymentMethod = 'split';
        _syncSecondaryPaymentDetails();
      }
    }

    double remainingBalance = (totalAmount - cashAmount - cardAmount).clamp(
      0.0,
      double.infinity,
    );
    _emitLoaded(remainingBalance);
  }

  void _syncSecondaryPaymentDetails() {
    if (paymentMethod == 'cash' || paymentMethod == 'card') {
      secondaryPaymentMethod = '';
      secondaryPaymentAmount = '';
      return;
    }

    if (paymentMethod == 'split') {
      if (orderPaymentMethod == 'cash') {
        secondaryPaymentMethod = 'card';
        secondaryPaymentAmount = cardAmount.toStringAsFixed(2);
      } else if (orderPaymentMethod == 'card') {
        secondaryPaymentMethod = 'cash';
        secondaryPaymentAmount = cashAmount.toStringAsFixed(2);
      } else {
        secondaryPaymentMethod = '';
        secondaryPaymentAmount = '';
      }
    }
  }

  void _emitLoaded(double remainingBalance) {
    if (state is PaymentCollectionLoaded) {
      emit(
        (state as PaymentCollectionLoaded).copyWith(
          cashAmount: cashAmount,
          cardAmount: cardAmount,
          paymentMethod: paymentMethod,
          orderPaymentMethod: orderPaymentMethod,
          secondaryPaymentMethod: secondaryPaymentMethod,
          secondaryPaymentAmount: secondaryPaymentAmount,
          balanceRemaining: remainingBalance,
        ),
      );
    }
  }

  bool _isTotalCollected() {
    return (cashAmount + cardAmount - totalAmount).abs() < 0.005;
  }

  void collectPayment(
    BuildContext context,
    String status,
    bool paymentCollected,
    String secondaryPaymentMethod,
    String secondaryPaymentAmount,
  ) async {
    if (!_isTotalCollected()) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: 'Please collect the full amount',
        ),
      );
      return;
    }

    var logger = Logger();

    logger.i(
      'Collecting payment with details: '
      'Total: $totalAmount, Cash: $cashAmount, Card: $cardAmount, '
      'Payment Method: $paymentMethod, Order Payment Method: $orderPaymentMethod, '
      'Secondary Payment Method: $secondaryPaymentMethod, '
      'Secondary Payment Amount: $secondaryPaymentAmount',
    );

    await updateMainOrderStat(
      status,
      "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order ",
      context,
      paymentCollected: paymentCollected,
      secondaryPaymentMethod: secondaryPaymentMethod,
      secondaryPaymentAmount: secondaryPaymentAmount,
    );

    // emit(PaymentCollectionInProgress());

    // Future.delayed(Duration(seconds: 2), () {
    //   emit(PaymentCollectionSuccess());
    // });
  }

  updateMainOrderStat(
    String status,
    String comment,
    BuildContext context, {
    required bool paymentCollected,
    required String secondaryPaymentMethod,
    required String secondaryPaymentAmount,
  }) async {
    try {
      emit(PaymentCollectionInProgress());
      // Step 1: Get current position
      Position position = await Geolocator.getCurrentPosition();

      // Step 2: Store lat & long in shared preferences
      String lat = position.latitude.toString();
      String long = position.longitude.toString();

      await PreferenceUtils.storeDataToShared("driverlat", lat);
      await PreferenceUtils.storeDataToShared("driverlong", long);

      final resp = await serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderResponseItem!.subgroupIdentifier,
        orderstatus: status,
        comment:
            comment == ""
                ? "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order"
                : comment,
        userid: UserController().profile.id,
        latitude: lat,
        longitude: long,
        paymentCollected: paymentCollected,
        secondaryPaymentMethod: secondaryPaymentMethod,
        secondaryPaymentAmount: secondaryPaymentAmount,
      );

      // final resp = await serviceLocator.tradingApi.updateMainOrderStat(
      //   orderid: orderResponseItem!.subgroupIdentifier,
      //   orderstatus: status,
      //   comment:
      //       "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order",
      //   userid: UserController().profile.id,
      //   latitude: '25.22018977162075',
      //   longitude: '51.49574356933962',
      // );

      Map<String, dynamic> data = jsonDecode(resp.body);

      if (data['status'] == 200) {
        if (data['message'].toString().contains(
          "Please mark order from delivered location",
        )) {
          toastification.show(
            backgroundColor: customColors().warning,
            title: TranslatedText(
              text: "Please mark order from \n delivered location",
              maxLines: 2,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          // updatestat = false;

          // emit(PaymentCollectionState());
        } else {
          toastification.show(
            backgroundColor: customColors().secretGarden,
            title: TranslatedText(
              text: "Order Status Updated",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          Navigator.of(context).popUntil((route) => route.isFirst);

          context.gNavigationService.openDriverDashBoardPage(context);
        }
      } else {
        toastification.show(
          backgroundColor: customColors().warning,
          title: TranslatedText(
            text:
                data['message'] ?? "Status Update Failed Please Try Again..!.",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        // emit(DeliveryStatusUpdateState());
      }
    } catch (e) {
      toastification.show(
        backgroundColor: customColors().warning,
        title: TranslatedText(
          text: "Status Update Failed Please Try Again..!.",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );
      // emit(DeliveryStatusUpdateState());
    }
  }
}
