import 'dart:convert';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:toastification/toastification.dart';

enum _PayMethod { cash, card, split }

class PaymentCollectionPage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  final DataItem order;

  const PaymentCollectionPage({
    super.key,
    required this.serviceLocator,
    required this.order,
  });

  @override
  State<PaymentCollectionPage> createState() => _PaymentCollectionPageState();
}

class _PaymentCollectionPageState extends State<PaymentCollectionPage> {
  _PayMethod _method = _PayMethod.cash;
  late final TextEditingController _cashCtrl;
  late final TextEditingController _cardCtrl;
  String _currency = 'QAR';
  bool _submitting = false;

  double get _total => widget.order.order.total;

  double _parse(String value) =>
      double.tryParse(value.replaceAll(',', '').trim()) ?? 0;

  double get _cash => _parse(_cashCtrl.text);
  double get _card => _parse(_cardCtrl.text);
  double get _collected => _cash + _card;
  double get _balance => _total - _collected;
  bool get _isBalanced => _balance.abs() < 0.009 && _collected >= 0;

  String _fmt(double value) => value.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _cashCtrl = TextEditingController(text: _fmt(_total));
    _cardCtrl = TextEditingController(text: _fmt(0));
    getCurrency().then((value) {
      if (mounted) setState(() => _currency = value);
    });
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _selectMethod(_PayMethod method) {
    setState(() {
      _method = method;
      if (method == _PayMethod.cash) {
        _cashCtrl.text = _fmt(_total);
        _cardCtrl.text = _fmt(0);
      } else if (method == _PayMethod.card) {
        _cashCtrl.text = _fmt(0);
        _cardCtrl.text = _fmt(_total);
      }
    });
  }

  String get _paymentMethodValue {
    switch (_method) {
      case _PayMethod.cash:
        return 'cashondelivery';
      case _PayMethod.card:
        return 'banktransfer';
      case _PayMethod.split:
        return 'split';
    }
  }

  Future<void> _submit() async {
    if (!_isBalanced || _submitting) return;
    setState(() => _submitting = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      final lat = position.latitude.toString();
      final long = position.longitude.toString();
      await PreferenceUtils.storeDataToShared("driverlat", lat);
      await PreferenceUtils.storeDataToShared("driverlong", long);

      final token =
          await PreferenceUtils.getDataFromShared("usertoken") ??
          UserController().profile.token.toString();

      final resp = await widget.serviceLocator.tradingApi.updateMainOrderStat(
        orderid: widget.order.order.subgroupIdentifier,
        orderstatus: "complete",
        comment:
            "${UserController().profile.name} (${UserController().profile.empId}) collected ${_fmt(_collected)} $_currency and delivered this order",
        userid: UserController().profile.id.toString(),
        latitude: lat,
        longitude: long,
        token1: token,
        paymentMethod: _paymentMethodValue,
        grandTotal: _fmt(_total),
        dueAmount: _fmt(0),
        cashAmount: _fmt(_cash),
        cardAmount: _fmt(_card),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
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
          setState(() => _submitting = false);
          return;
        }

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
      } else {
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
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (!mounted) return;
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
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = const Color(0xFF3D3D3D);
    return Scaffold(
      backgroundColor: customColors().backgroundPrimary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          backgroundColor: customColors().backgroundPrimary,
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: customColors().backgroundTertiary),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.gNavigationService.back(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 17),
                ),
                Expanded(
                  child: TranslatedText(
                    text: "Payment Collection",
                    textAlign: TextAlign.center,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: dark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TranslatedText(
                          text: "Total Amount to Collect",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Regular,
                            color: FontColor.White,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_fmt(_total)} $_currency",
                          style: customTextStyle(
                            fontStyle: FontStyle.HeaderS_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TranslatedText(
                    text: "Select Payment Method",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _methodTile(
                        _PayMethod.cash,
                        "Cash on\nDelivery",
                        Icons.payments_outlined,
                      ),
                      const SizedBox(width: 8),
                      _methodTile(
                        _PayMethod.card,
                        "Card on\nDelivery",
                        Icons.credit_card,
                      ),
                      const SizedBox(width: 8),
                      _methodTile(
                        _PayMethod.split,
                        "Split\nPayment",
                        Icons.layers_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _amountField(
                    label: "Cash Amount",
                    controller: _cashCtrl,
                    enabled: _method != _PayMethod.card,
                  ),
                  const SizedBox(height: 12),
                  _amountField(
                    label: "Card Amount",
                    controller: _cardCtrl,
                    enabled: _method != _PayMethod.cash,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _isBalanced
                              ? customColors().secretGarden.withOpacity(0.12)
                              : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                              _isBalanced
                                  ? customColors().secretGarden
                                  : const Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TranslatedText(
                            text:
                                _isBalanced
                                    ? "Amount matched ${_fmt(_total)} $_currency"
                                    : "Balance to Collect ${_fmt(_balance.abs())} $_currency",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TranslatedText(
                    text: "Collection Summary",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_cash > 0) _summaryRow("Cash", _cash),
                  if (_card > 0) _summaryRow("Card", _card),
                  const Divider(),
                  _summaryRow("Total collected", _collected, bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: BasketButton(
            text: "Mark Delivered",
            enabled: _isBalanced && !_submitting,
            loading: _submitting,
            bgcolor: customColors().green600,
            onpress: _isBalanced ? _submit : null,
            textStyle: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodTile(_PayMethod method, String label, IconData icon) {
    final selected = _method == method;
    return Expanded(
      child: InkWell(
        onTap: () => _selectMethod(method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3D3D3D) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? const Color(0xFF3D3D3D)
                      : customColors().fontPrimary,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : customColors().fontPrimary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyS_Bold,
                  color: selected ? FontColor.White : FontColor.FontPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          text: label,
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixText: "$_currency  ",
            suffixIcon: Icon(
              Icons.edit,
              color: customColors().fontPrimary,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : customColors().backgroundTertiary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: customColors().backgroundTertiary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: customColors().backgroundTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TranslatedText(
            text: label,
            style: customTextStyle(
              fontStyle: bold ? FontStyle.BodyL_Bold : FontStyle.BodyM_Regular,
              color: FontColor.FontPrimary,
            ),
          ),
          Text(
            "${_fmt(amount)} $_currency",
            style: customTextStyle(
              fontStyle: bold ? FontStyle.BodyL_Bold : FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
