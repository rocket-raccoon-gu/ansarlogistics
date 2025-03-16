import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/Section_In/features/components/ar_branch_section_product_list_item.dart';
import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class HomeSectionIncharge extends StatefulWidget {
  const HomeSectionIncharge({super.key});

  @override
  State<HomeSectionIncharge> createState() => _HomeSectionInchargeState();
}

class _HomeSectionInchargeState extends State<HomeSectionIncharge> {
  bool searchactive = false;

  final _searchcontroller = TextEditingController();

  List<Map<String, dynamic>> maplist = [
    {"name": "All", "id": 17},
    {"name": "Fresh Chickens", "id": 18},
    {"name": "Beef", "id": 19},
    {"name": "Mutton", "id": 20},
    {"name": "Lamb", "id": 22},
  ];

  int selectedcat = -1;

  GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

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
              if (UserController.userController.profile.branchCode == "Q013" ||
                  UserController.userController.profile.branchCode == "Q009")
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: customColors().fontTertiary,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: CustomSearchField(
                            searchFormKey: _ordersearchFormKey,
                            keyboardType: TextInputType.text,
                            focus: searchactive,
                            onFilter: () {},
                            onSearch: (p0) {
                              BlocProvider.of<HomeSectionInchargeCubit>(
                                context,
                              ).updatesearchorder(
                                UserController().sectionitems,
                                p0.toString(),
                              );
                            },
                            controller: _searchcontroller,
                          ),
                        ),
                      ),
                      UserController.userController.profile.empId ==
                                  "ahqa_butch" ||
                              UserController.userController.userName ==
                                  "alkhor_butch"
                          ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SizedBox(
                              height: 30.0,
                              child: MediaQuery.removePadding(
                                removeTop: true,
                                removeBottom: true,
                                context: context,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: maplist.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 3.0,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedcat = index;
                                                  BlocProvider.of<
                                                    HomeSectionInchargeCubit
                                                  >(context).updateloadProducts(
                                                    maplist[selectedcat]['id'],
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    index == 0
                                                        ? const EdgeInsets.symmetric(
                                                          horizontal: 12.0,
                                                        )
                                                        : const EdgeInsets.symmetric(
                                                          horizontal: 15.0,
                                                        ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedcat == index
                                                          ? customColors()
                                                              .green4
                                                          : null,
                                                  border: Border.all(
                                                    color:
                                                        customColors()
                                                            .fontSecondary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        3.0,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    maplist[index]['name'],
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyL_Bold,
                                                      color:
                                                          FontColor.FontPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : SizedBox(),
                      Expanded(
                        child: Column(
                          children: [
                            if (state is HomeSectionInchargeLoading)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [loadingindecator()],
                                ),
                              )
                            else if (state is HomeSectionInchargeInitial)
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    if (selectedcat != -1) {
                                      BlocProvider.of<HomeSectionInchargeCubit>(
                                        context,
                                      ).updateloadProducts(
                                        maplist[selectedcat]['id'],
                                      );
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 10.0,
                                          ),
                                          child: Column(
                                            children: [
                                              state.sectionitems.isEmpty
                                                  ? Expanded(
                                                    child: ListView(
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 80.0,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Image.network(
                                                                '${noimageurl}',
                                                                height: 180.0,
                                                                width: 180.0,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      top: 8.0,
                                                                    ),
                                                                child: Text(
                                                                  "No Products Found..!",
                                                                  style: customTextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .HeaderXS_SemiBold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : Expanded(
                                                    child: MediaQuery.removePadding(
                                                      removeTop: true,
                                                      context: context,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            state
                                                                .sectionitems
                                                                .length,
                                                        shrinkWrap: true,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          if (UserController
                                                                  .userController
                                                                  .profile
                                                                  .branchCode ==
                                                              "Q013") {
                                                            return SectionProductListItem(
                                                              sectionitem:
                                                                  state
                                                                      .sectionitems[index],
                                                              onSectionChanged: (
                                                                p0,
                                                                p1,
                                                                p2,
                                                              ) {
                                                                context
                                                                    .read<
                                                                      HomeSectionInchargeCubit
                                                                    >()
                                                                    .addToStockStatusList(
                                                                      p0,
                                                                      p1,
                                                                      p2,
                                                                    );
                                                              },
                                                            );
                                                          } else {
                                                            return Container();
                                                            // return BranchSectionProductListItem(
                                                            //     sectionitem: state
                                                            //             .sectionitems[
                                                            //         index],
                                                            //     onSectionChanged:
                                                            //         (p0, p1, p2) {
                                                            //       context
                                                            //           .read<
                                                            //               HomeSectionInchargeCubit>()
                                                            //           .addToStockStatusList(
                                                            //               p0, p1, p2);
                                                            //     },
                                                            //     branchdatum: context
                                                            //         .read<
                                                            //             HomeSectionInchargeCubit>()
                                                            //         .branchdata);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                            ],
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
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: customColors().fontTertiary,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: CustomSearchField(
                            searchFormKey: _ordersearchFormKey,
                            keyboardType: TextInputType.text,
                            focus: searchactive,
                            onFilter: () {},
                            onSearch: (p0) {
                              // BlocProvider.of<HomeSectionInchargeCubit>(context)
                              //     .updatesearchorderar(
                              //         UserController().branchdatalist,
                              //         p0.toString());
                            },
                            controller: _searchcontroller,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (state is HomeSectionInchargeLoading)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [loadingindecator()],
                                ),
                              )
                            else if (state is HomeSectionInchargeInitial)
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    if (selectedcat != -1) {
                                      BlocProvider.of<HomeSectionInchargeCubit>(
                                        context,
                                      ).updateloadProducts(
                                        maplist[selectedcat]['id'],
                                      );
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 10.0,
                                          ),
                                          child: Column(
                                            children: [
                                              state.branchdata.isEmpty
                                                  ? Expanded(
                                                    child: ListView(
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 80.0,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Lottie.asset(
                                                                'assets/nofound_data.json',
                                                                height: 180.0,
                                                                width: 180.0,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      top: 8.0,
                                                                    ),
                                                                child: Text(
                                                                  "No Products Found..!",
                                                                  style: customTextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .HeaderXS_SemiBold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : Expanded(
                                                    child: MediaQuery.removePadding(
                                                      context: context,
                                                      removeTop: true,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            state
                                                                .branchdata
                                                                .length,
                                                        shrinkWrap: true,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          return ArBranchSectionProductListItem(
                                                            branchdatum:
                                                                state
                                                                    .branchdata[index],
                                                            onSectionChanged: (
                                                              p0,
                                                              p1,
                                                              p2,
                                                            ) {
                                                              context
                                                                  .read<
                                                                    HomeSectionInchargeCubit
                                                                  >()
                                                                  .addToStockStatusList(
                                                                    p0,
                                                                    p1,
                                                                    p2,
                                                                  );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                            ],
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
                ),
            ],
          );
        },
      ),
    );
  }
}
