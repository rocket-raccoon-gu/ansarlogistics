import 'package:ansarlogistics/Section_In/features/components/ar_branch_section_product_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArBranchSection extends StatefulWidget {
  const ArBranchSection({super.key});

  @override
  State<ArBranchSection> createState() => _ArBranchSectionState();
}

class _ArBranchSectionState extends State<ArBranchSection> {
  GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

  bool searchactive = false;

  final _searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: customColors().fontTertiary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CustomSearchField(
              searchFormKey: _ordersearchFormKey,
              keyboardType: TextInputType.text,
              focus:
                  BlocProvider.of<HomeSectionInchargeCubit>(
                    context,
                  ).searchactive,
              onFilter: () {},
              onSearch: (p0) {
                BlocProvider.of<HomeSectionInchargeCubit>(
                  context,
                ).updateSearchOrderAR(
                  UserController().branchdata,
                  p0.toString(),
                );
                // if (p0 != '') {
                //   setState(() {
                //     searchactive = true;
                //   });
                // } else {
                //   setState(() {
                //     searchactive = false;
                //   });
                // }
              },
              controller: _searchcontroller,
            ),
          ),
        ),

        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                if (BlocProvider.of<HomeSectionInchargeCubit>(
                      context,
                    ).searchactive &&
                    BlocProvider.of<HomeSectionInchargeCubit>(
                      context,
                    ).branchdata.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ListView.builder(
                      itemCount:
                          BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).branchdata.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ArBranchSectionProductListItem(
                          branchdatum:
                              BlocProvider.of<HomeSectionInchargeCubit>(
                                context,
                              ).branchdata[index],
                          onSectionChanged: (p0, p1, p2) {},
                        );
                      },
                    ),
                  )
                else if (BlocProvider.of<HomeSectionInchargeCubit>(
                      context,
                    ).searchactive &&
                    BlocProvider.of<HomeSectionInchargeCubit>(
                      context,
                    ).searchresult.isEmpty)
                  Column(children: [])
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ListView.builder(
                      itemCount:
                          BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).branchdata.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ArBranchSectionProductListItem(
                          branchdatum:
                              BlocProvider.of<HomeSectionInchargeCubit>(
                                context,
                              ).branchdata[index],
                          onSectionChanged: (p0, p1, p2) {
                            context
                                .read<HomeSectionInchargeCubit>()
                                .addToStockStatusList(p0, p1, p2);
                          },
                        );
                      },
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
