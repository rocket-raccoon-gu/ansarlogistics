import 'dart:io';

import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatefulWidget {
  Function()? onpressfind;
  bool ispicker;
  bool? isload;
  CustomAppBar({
    super.key,
    required this.onpressfind,
    required this.ispicker,
    this.isload = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: mheight * .012),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () async {
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    showSnackBar(
                      context: context,
                      snackBar: showSuccessDialogue(
                        message: '${position.latitude},${position.longitude}',
                      ),
                    );
                  },
                  child: Text(
                    "${getTranslate(context, 'Hi')}, ${UserController.userController.profile.name}",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_SemiBold_lato,
                      color: FontColor.FontPrimary,
                    ),
                    maxLines:
                        2, // Allow the text to be displayed in up to 2 lines
                    softWrap: true, // Enable text wrapping
                    overflow:
                        TextOverflow.ellipsis, // Handle overflow with ellipsis
                  ),
                ),
              ),

              // Flexible(
              //   child: FutureBuilder<String?>(
              //     future: getTranslateto(UserController
              //         .userController.profile.name), // Pass the keyword here
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return CircularProgressIndicator(); // Show a loading indicator while waiting for translation
              //       } else if (snapshot.hasError) {
              //         return Text(
              //             'Error: ${snapshot.error}'); // Handle any errors
              //       } else if (snapshot.hasData) {
              //         return Text(
              //           "${getTranslate(context, 'Hi')},${snapshot.data}", // Display the translated text
              //           style: customTextStyle(
              //             fontStyle: FontStyle.BodyL_SemiBold_lato,
              //             color: FontColor.FontPrimary,
              //           ),
              //           maxLines: 2,
              //           softWrap: true,
              //           overflow: TextOverflow.ellipsis,
              //         );
              //       } else {
              //         return Text(
              //             "Translation not available"); // Handle null or no translation
              //       }
              //     },
              //   ),
              // ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.ispicker
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13.0),
                          child: InkWell(
                            onTap: () async {
                              var androidUrl = "";

                              var contact = "+97460094446";
                              androidUrl =
                                  "whatsapp://send?phone=$contact&text=Hi I'm, ${UserController.userController.profile.name} I need some help";

                              var iosUrl =
                                  "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

                              try {
                                if (Platform.isIOS) {
                                  await launchUrl(Uri.parse(iosUrl));
                                } else {
                                  await launchUrl(Uri.parse(androidUrl));
                                }
                              } on Exception {
                                //  EasyLoading.showError('WhatsApp is not installed.');
                                showSnackBar(
                                  context: context,
                                  snackBar: showErrorDialogue(
                                    errorMessage: "Whatsapp msg not sended..!",
                                  ),
                                );
                              }
                            },
                            child: ImageIcon(
                              AssetImage('assets/customer.png'),
                              color: customColors().grey,
                              size: 30,
                            ),
                          ),
                        )
                        : !widget.isload!
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: BasketButtonwithIcon(
                            loading: widget.isload!,
                            buttonwidth: 150.0,
                            bgcolor: customColors().fontPrimary,
                            image: 'assets/binocular.png',
                            text: "Find Orders",
                            textStyle: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.White,
                            ),
                            onpress: widget.onpressfind,
                          ),
                        )
                        : SizedBox(),
                    SizedBox(width: 10.0),
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
