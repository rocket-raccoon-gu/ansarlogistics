import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/components/custom_app_components/tile_card_widget.dart';
import 'package:ansarlogistics/constants/methods.dart';
// import 'package:ansarlogistics/localization/language_button.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfilePage extends StatefulWidget {
  final ServiceLocator serviceLocator;

  const ProfilePage({super.key, required this.serviceLocator});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  String? langval;

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    langval = await PreferenceUtils.getDataFromShared('language');

    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => ProfilePageCubit(
                  serviceLocator: widget.serviceLocator,
                  context: context,
                ),
          ),
        ],
        child: BlocBuilder<ProfilePageCubit, ProfilePageState>(
          builder: (context, state) {
            if (state is ProfilePageInitialState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: HexColor('#F9FBFF'),
                      border: Border(
                        bottom: BorderSide(
                          width: 2.0,
                          color: customColors().backgroundTertiary,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: customColors().backgroundTertiary.withOpacity(
                            1.0,
                          ),
                          spreadRadius: 3,
                          blurRadius: 5,
                          // offset: Offset(0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: mheight * .012),
                      child: Row(
                        children: [
                          // IconButton(
                          //     onPressed: () {
                          //       context.gNavigationService.back(context);
                          //     },
                          //     icon: Icon(
                          //       Icons.arrow_back_ios,
                          //       size: 17.0,
                          //     )),
                          Expanded(
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      bottom: 16.0,
                                      top: 8.0,
                                    ),
                                    // child: Text(
                                    //   "Profile ",
                                    //   style: customTextStyle(
                                    //     fontStyle: FontStyle.BodyL_Bold,
                                    //     color: FontColor.FontPrimary,
                                    //   ),
                                    // ),
                                    child: TranslatedText(
                                      text: "Profile",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TileCardWidget(),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: [
                        TranslatedText(
                          text: "USER INFO",
                          style: customTextStyle(
                            fontStyle: FontStyle.Inter_Medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    // Image.asset(
                                    //   state.listmap[index.toString()]['img'],
                                    //   height: 20,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      child: TranslatedText(
                                        text: "Name",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyL_SemiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  TranslatedText(
                                    text:
                                        UserController
                                            .userController
                                            .profile
                                            .name,
                                  ),
                                  // Icon(
                                  //   Icons.arrow_forward_ios,
                                  //   size: 20,
                                  // )
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    // Image.asset(
                                    //   state.listmap[index.toString()]['img'],
                                    //   height: 20,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      child: TranslatedText(
                                        text: "User ID",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyL_SemiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    UserController.userController.profile.empId,
                                  ),
                                  // Icon(
                                  //   Icons.arrow_forward_ios,
                                  //   size: 20,
                                  // )
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 22.0,
                          ),
                          child: InkWell(
                            onTap: () {
                              Map<String, dynamic> data = {"selected": 0};

                              context.gNavigationService.openNewScannerPage2(
                                context,
                                data,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Image.asset(
                                    //   state.listmap[index.toString()]['img'],
                                    //   height: 20,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      child: TranslatedText(
                                        text: "Switch to Scanner",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyL_SemiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Text(
                                    //   UserController.userController.profile.empId,
                                    // ),
                                    Icon(Icons.arrow_forward_ios, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: ListView.builder(
                  //       shrinkWrap: true,
                  //       itemCount:
                  //           context.read<ProfilePageCubit>().profilelist.length,
                  //       itemBuilder: (context, index) {
                  //         return InkWell(
                  //           onTap: () async {
                  //             if (index == 3) {
                  //               Map<String, dynamic> data = {"selected": 0};

                  //               context.gNavigationService.openNewScannerPage2(
                  //                 context,
                  //                 data,
                  //               );
                  //               // } else if (index == 4) {
                  //               //   context.gNavigationService
                  //               //       .openReplacementMarkIFAtemsPage(context, {});
                  //             }
                  //           },
                  //           child: Container(
                  //             padding: const EdgeInsets.only(
                  //               left: 12.0,
                  //               right: 12.0,
                  //               top: 12.0,
                  //               bottom: 8.0,
                  //             ),
                  //             child: Column(
                  //               children: [
                  //                 Row(
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     Row(
                  //                       children: [
                  //                         // Image.asset(
                  //                         //   state.listmap[index.toString()]['img'],
                  //                         //   height: 20,
                  //                         // ),
                  //                         Padding(
                  //                           padding: const EdgeInsets.only(
                  //                             left: 8.0,
                  //                           ),
                  //                           child: Text(
                  //                             context
                  //                                 .read<ProfilePageCubit>()
                  //                                 .profilelist[index
                  //                                 .toString()]['title'],
                  //                             style: customTextStyle(
                  //                               fontStyle:
                  //                                   FontStyle.BodyL_SemiBold,
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     Row(
                  //                       children: [
                  //                         Text(
                  //                           context
                  //                               .read<ProfilePageCubit>()
                  //                               .profilelist[index
                  //                               .toString()]['value'],
                  //                         ),
                  //                         // Icon(
                  //                         //   Icons.arrow_forward_ios,
                  //                         //   size: 20,
                  //                         // )
                  //                       ],
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(
                        //   "Language",
                        //   style: customTextStyle(
                        //     fontStyle: FontStyle.BodyL_SemiBold,
                        //   ),
                        // ),
                        TranslatedText(
                          text: "Language",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_SemiBold,
                          ),
                        ),
                        // LanguageButton(indexval: langval == 'en' ? 1 : 2),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TranslatedText(
                          text: "Region",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_SemiBold,
                          ),
                        ),
                        Image.asset('assets/qatar.png', height: 60.0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TranslatedText(
                          text: "App Version - ",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_SemiBold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                        Text(
                          "${_packageInfo.version}",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_SemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      top: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {},
                            child: BasketButton(
                              text: "Check for updates",
                              textStyle: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 9.0),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              BlocProvider.of<ProfilePageCubit>(
                                context,
                              ).updateuserstat(0);
                              await logout(context);
                            },
                            child: BasketButtonwithIcon(
                              bgcolor: customColors().dodgerBlue,
                              text: "Logout",
                              textStyle: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.White,
                              ),
                              image: "assets/logout-new.png",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column();
            }
          },
        ),
      ),
    );
  }
}
