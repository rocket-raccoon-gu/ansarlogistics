import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_cubit.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TileCardWidget extends StatefulWidget {
  const TileCardWidget({super.key});

  @override
  State<TileCardWidget> createState() => _TileCardWidgetState();
}

class _TileCardWidgetState extends State<TileCardWidget> {
  bool value = UserController().profile.availabilityStatus == 1 ? true : false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: customColors().backgroundPrimary),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          // Image.asset("assets/user-profile.png"),
                          Image.asset("assets/user-profile.png"),
                          UserController().profile.availabilityStatus == 1
                              ? Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    // BlocProvider.of<ProfileCubit>(context)
                                    //     .fetchImage();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: HexColor('#C8E93D'),
                                    ),
                                    child: Center(
                                      child: TranslatedText(
                                        text: "On Duty",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyL_Bold,
                                          color: FontColor.White,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 7.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: customColors().fontTertiary
                                        .withValues(alpha: 0.7),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Break",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.White,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    AnimatedSwitch(
                      defaultval: value,
                      onTap: () {
                        BlocProvider.of<ProfilePageCubit>(
                          context,
                        ).updateuserstat(value ? 0 : 1).then((v) {
                          if (v) {
                            setState(() {
                              value = !value;
                            });
                          }
                        });
                      },
                    ),
                    // AnimatedSwitchToggle()
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
