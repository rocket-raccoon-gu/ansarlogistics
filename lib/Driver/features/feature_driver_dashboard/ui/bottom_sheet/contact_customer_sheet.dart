import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class ContactCustomerSheet extends StatelessWidget {
  final DataItem orderResponseItem;
  ContactCustomerSheet({super.key, required this.orderResponseItem});

  CallLogs c1 = CallLogs();

  Future<void> handleCall() async {
    String contactsplit =
        orderResponseItem.telephone.length < 8
            ? "+974${orderResponseItem.telephone}"
            : "${orderResponseItem.telephone}";

    try {
      c1.call(contactsplit, () async {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TranslatedText(
                text: "Contact Customer",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      context.gNavigationService.back(context);

                      await handleCall();
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset("assets/telephone.png", height: 60.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TranslatedText(
                              text: "Call Direct",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await whatsapp(
                        '',
                        orderResponseItem.telephone.trim(),
                        context,
                        orderResponseItem.subgroupIdentifier,
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset("assets/whatsapp.png", height: 60.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TranslatedText(
                              text: "Whats App",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
