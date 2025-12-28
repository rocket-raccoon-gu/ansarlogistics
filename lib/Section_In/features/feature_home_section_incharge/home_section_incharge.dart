import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSectionIncharge extends StatefulWidget {
  const HomeSectionIncharge({super.key});

  @override
  State<HomeSectionIncharge> createState() => _HomeSectionInchargeState();
}

class _HomeSectionInchargeState extends State<HomeSectionIncharge> {
  bool searchactive = false;

  List<Map<String, dynamic>> maplist = [
    {"name": "All", "id": 17},
    {"name": "Fresh Chickens", "id": 18},
    {"name": "Beef", "id": 19},
    {"name": "Mutton", "id": 20},
    {"name": "Lamb", "id": 22},
  ];

  int selectedcat = -1;

  final Set<String> updatingSkus = Set<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Scaffold(
      backgroundColor: customColors().backgroundPrimary,
      body: BlocBuilder<HomeSectionInchargeCubit, HomeSectionInchargeState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: mheight * .062),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Hi, ${UserController.userController.profile.name}",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_SemiBold_lato,
                            color: FontColor.FontPrimary,
                          ),
                          maxLines:
                              2, // Allow the text to be displayed in up to 2 lines
                          softWrap: true, // Enable text wrapping
                          overflow:
                              TextOverflow
                                  .ellipsis, // Handle overflow with ellipsis
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (UserController
                                      .userController
                                      .profile
                                      .branchCode !=
                                  'Q013' &&
                              (UserController.userController.profile.empId ==
                                      "veg_rayyan" ||
                                  UserController.userController.profile.empId ==
                                      "veg_rawdah"))
                            InkWell(
                              onTap: () {
                                context
                                    .read<HomeSectionInchargeCubit>()
                                    .clearSectionData();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: customColors().islandAqua,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Clear All",
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.White,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            SizedBox(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: InkWell(
                              onTap: () async {
                                await PreferenceUtils.removeDataFromShared(
                                  "userCode",
                                );
                                await PreferenceUtils.removeDataFromShared(
                                  "profiledetails",
                                );

                                await logout(context);
                              },
                              child: Image.asset(
                                'assets/logout.png',
                                height: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (selectedcat != -1) {
                      BlocProvider.of<HomeSectionInchargeCubit>(
                        context,
                      ).updateloadProducts(maplist[selectedcat]['id']);
                    } else {
                      BlocProvider.of<HomeSectionInchargeCubit>(
                        context,
                      ).loadProducts();
                    }
                  },
                  child: Container(
                    color: customColors().backgroundPrimary,
                    child: Stack(
                      children: [
                        getSection(
                          UserController.userController.profile.branchCode,
                          state,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
