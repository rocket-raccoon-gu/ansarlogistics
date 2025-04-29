import 'dart:io';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatefulWidget {
  Function()? onpressfind;
  bool ispicker;
  bool? isload;
  bool isphoto;
  CustomAppBar({
    super.key,
    required this.onpressfind,
    required this.ispicker,
    this.isload = false,
    this.isphoto = false,
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
                  onTap: () async {},

                  child: Text(
                    "Hi, ${UserController.userController.profile.name}",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_SemiBold_lato,
                      color: FontColor.FontPrimary,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              !widget.isphoto
                  ? Flexible(
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
                                        errorMessage:
                                            "Whatsapp msg not sended..!",
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
                  )
                  : Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.0),
                          child: InkWell(
                            onTap: () async {
                              await PreferenceUtils.removeDataFromShared(
                                "userCode",
                              );
                              await PreferenceUtils.removeDataFromShared(
                                "profiledetails",
                              );
                              await PreferenceUtils.clear();

                              await logout(context);

                              // BlocProvider.of<HomeSectionInchargeCubit>(context)
                              //     .updateLogoutStat(0);
                            },
                            child: Image.asset('assets/logout.png', height: 28),
                          ),
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
