import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/sheet_button.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:toastification/toastification.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

Future<void> showDriverCustomerTopModel(
  BuildContext context,
  ServiceLocator serviceLocator,
  DataItem order,
) {
  return showTopModalSheet<void>(
    context,
    DriverCustomerDetailsSheet(
      serviceLocator: serviceLocator,
      orderResponseItem: order,
      onTapClose: () {
        UserController().cancelreason = "Please Select Reason";
        context.gNavigationService.back(context);
      },
    ),
  );
}

class DriverCustomerDetailsSheet extends StatefulWidget {
  final Function()? onTapClose;
  final ServiceLocator serviceLocator;
  final DataItem orderResponseItem;

  const DriverCustomerDetailsSheet({
    super.key,
    required this.onTapClose,
    required this.serviceLocator,
    required this.orderResponseItem,
  });

  @override
  State<DriverCustomerDetailsSheet> createState() =>
      _DriverCustomerDetailsSheetState();
}

class _DriverCustomerDetailsSheetState extends State<DriverCustomerDetailsSheet> {
  final CallLogs _callLogs = CallLogs();
  bool _confirmNotAnswer = false;
  bool _updating = false;

  String get _phone {
    final raw = widget.orderResponseItem.customer.mobileNumber.trim();
    if (raw.isEmpty) return "";
    if (raw.startsWith('+') || raw.startsWith('974') || raw.length >= 8) {
      return raw;
    }
    return '+974$raw';
  }

  String get _addressLine {
    final address = widget.orderResponseItem.address;
    final parts = [
      if (address.name.trim().isNotEmpty) address.name.trim(),
      if (address.building.trim().isNotEmpty) 'Bldg ${address.building.trim()}',
      if (address.apartment.trim().isNotEmpty)
        'Apt ${address.apartment.trim()}',
      if (address.street.trim().isNotEmpty) address.street.trim(),
      if (address.zone.trim().isNotEmpty) 'Zone ${address.zone.trim()}',
      if (address.floor.trim().isNotEmpty) 'Floor ${address.floor.trim()}',
    ];
    return parts.join(', ');
  }

  bool get _canMarkNotAnswer {
    final status = widget.orderResponseItem.order.status;
    return status != 'complete' &&
        status != 'customer_not_answer' &&
        status != 'canceled' &&
        status != 'canceled_by_team';
  }

  Future<void> _callCustomer() async {
    if (_phone.isEmpty) return;
    try {
      _callLogs.call(_phone, () async {});
    } catch (_) {}
  }

  Future<void> _whatsappCustomer() async {
    if (_phone.isEmpty) return;
    await whatsapp(
      '',
      _phone,
      context,
      widget.orderResponseItem.order.subgroupIdentifier,
    );
  }

  Future<void> _markCustomerNotAnswer() async {
    if (_updating) return;
    setState(() => _updating = true);

    try {
      final token = await PreferenceUtils.getDataFromShared("usertoken") ?? '';
      final resp = await widget.serviceLocator.tradingApi.updateMainOrderStat(
        orderid: widget.orderResponseItem.order.subgroupIdentifier,
        orderstatus: "customer_not_answer",
        comment:
            "${UserController().profile.name} (${UserController().profile.empId}) marked the order customer not answer",
        userid: UserController().profile.id.toString(),
        latitude: UserController.userController.locationlatitude,
        longitude: UserController.userController.locationlongitude,
        token1: token,
      );

      if (resp.statusCode == 200) {
        toastification.show(
          backgroundColor: customColors().secretGarden,
          context: context,
          autoCloseDuration: const Duration(seconds: 5),
          title: TranslatedText(
            text: "Order is on Customer Not Answer",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        context.gNavigationService.openDriverDashBoardPage(context);
      } else {
        toastification.show(
          backgroundColor: customColors().carnationRed,
          context: context,
          autoCloseDuration: const Duration(seconds: 5),
          title: TranslatedText(
            text: "Send Request Failed Please Try Again...!",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        );
      }
    } catch (_) {
      toastification.show(
        backgroundColor: customColors().carnationRed,
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        title: TranslatedText(
          text: "Send Request Failed Please Try Again...!",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Widget _infoRow(String label, String value, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: HexColor('#F0F0F0')),
      ),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          TranslatedText(
            text: label,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? "—" : value,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.orderResponseItem.customer;
    final order = widget.orderResponseItem.order;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      color: customColors().backgroundPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TranslatedText(
                    text: "Customer Information",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ),
                InkWell(onTap: widget.onTapClose, child: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _infoRow("Customer Name", customer.name),
                    _infoRow("Email", customer.email),
                    _infoRow("Phone number", customer.mobileNumber),
                    _infoRow("Address", _addressLine, maxLines: 4),
                    _infoRow(
                      "Order",
                      order.subgroupIdentifier,
                    ),
                  ],
                ),
              ),
            ),
            if (_confirmNotAnswer && _canMarkNotAnswer)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BasketButton(
                  bgcolor: customColors().carnationRed,
                  loading: _updating,
                  text: "Customer Not Answering",
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                  onpress: _markCustomerNotAnswer,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SheetButton(
                      imagepath: 'assets/telephone.png',
                      sheettext: "Call",
                      height: 48,
                      onTapbtn: _callCustomer,
                    ),
                    SheetButton(
                      imagepath: 'assets/whatsapp.png',
                      sheettext: "WhatsApp",
                      height: 48,
                      onTapbtn: _whatsappCustomer,
                    ),
                    if (_canMarkNotAnswer)
                      SheetButton(
                        imagepath: 'assets/customer_ser.png',
                        sheettext: "Customer\nNot Answer",
                        height: 48,
                        onTapbtn: () {
                          setState(() => _confirmNotAnswer = true);
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
