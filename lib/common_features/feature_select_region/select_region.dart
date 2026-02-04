import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';

class SelectRegionPage extends StatefulWidget {
  const SelectRegionPage({super.key});

  @override
  State<SelectRegionPage> createState() => _SelectRegionPageState();
}

class _SelectRegionPageState extends State<SelectRegionPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'), // <-- BACKGROUND IMAGE
              fit: BoxFit.cover,
            ),
          ),
        ),
        GestureDetector(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: AppBar(
                elevation: 0,
                backgroundColor: customColors().backgroundPrimary,
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(top: 100.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       InkWell(
                //         onTap: () {
                //           FocusScope.of(context).unfocus();
                //         },
                //         child: Image.asset('assets/logo2.png', height: 100.0),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 100.0),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Please Choose Your Region.",
                        style: customTextStyle(
                          fontStyle: FontStyle.HeaderXS_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              // Map<String, dynamic> data = {};
                              // context.gNavigationService
                              //     .openWorkspacePage(context, data);

                              UserController
                                  .userController
                                  .mainbaseUrl = String.fromEnvironment(
                                'BASE_URL',
                                defaultValue:
                                    "https://pickerdriver-api.testuatah.com",
                              );
                              // await PreferenceUtils.storeDataToShared(
                              //     "mainbaseurl",
                              //     "https://admin-qatar.testuatah.com/");
                              await PreferenceUtils.storeDataToShared(
                                "region",
                                'QA',
                              );

                              await PreferenceUtils.storeDataToShared(
                                "mainbaseurl",
                                UserController.userController.mainbaseUrl,
                              );

                              // await logout(context);

                              if (context.mounted) {
                                context.gNavigationService.openLoginPage(
                                  context,
                                );
                              }
                            },
                            child: Image.asset('assets/qatar.png', height: 80),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: InkWell(
                              onTap: () async {
                                UserController
                                    .userController
                                    .mainbaseUrl = String.fromEnvironment(
                                  'BASE_URL',
                                  defaultValue:
                                      "https://pickerdriver-api-bh.testuatah.com",
                                );

                                await PreferenceUtils.storeDataToShared(
                                  "mainbaseurl",
                                  UserController.userController.mainbaseUrl,
                                );

                                await PreferenceUtils.storeDataToShared(
                                  "region",
                                  'BH',
                                );

                                if (!context.mounted) return;
                                context.gNavigationService.openLoginPage(
                                  context,
                                );

                                // await logout(context);
                                // Map<String, dynamic> data = {};
                                // context.gNavigationService
                                //     .openWorkspacePage(context, data);
                              },
                              child: Image.asset(
                                'assets/bahrain.png',
                                height: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                // Map<String, dynamic> data = {};
                                // context.gNavigationService
                                //     .openWorkspacePage(context, data);
                                UserController
                                    .userController
                                    .mainbaseUrl = String.fromEnvironment(
                                  'BASE_URL',
                                  defaultValue:
                                      "https://pickerdriver-api-uae.testuatah.com",
                                );
                                await PreferenceUtils.storeDataToShared(
                                  "mainbaseurl",
                                  UserController.userController.mainbaseUrl,
                                );

                                await PreferenceUtils.storeDataToShared(
                                  "region",
                                  'UAE',
                                );
                                if (!context.mounted) return;
                                context.gNavigationService.openLoginPage(
                                  context,
                                );
                                // await logout(context);
                              },
                              child: Image.asset('assets/uae.png', height: 80),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: InkWell(
                                onTap: () async {
                                  // Map<String, dynamic> data = {};
                                  // context.gNavigationService
                                  //     .openWorkspacePage(context, data);

                                  UserController
                                      .userController
                                      .mainbaseUrl = String.fromEnvironment(
                                    'BASE_URL',
                                    defaultValue:
                                        "https://pickerdriver-api-om.testuatah.com",
                                  );
                                  // await PreferenceUtils.storeDataToShared(
                                  //     "mainbaseurl",
                                  //     UserController
                                  //         .userController.mainbaseUrl);
                                  await PreferenceUtils.storeDataToShared(
                                    "region",
                                    'OM',
                                  );

                                  await PreferenceUtils.storeDataToShared(
                                    "mainbaseurl",
                                    UserController.userController.mainbaseUrl,
                                  );

                                  if (!context.mounted) return;
                                  context.gNavigationService.openLoginPage(
                                    context,
                                  );
                                  // await logout(context);
                                },
                                child: Image.asset(
                                  'assets/oman.png',
                                  height: 80,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
