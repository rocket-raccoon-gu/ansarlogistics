import 'dart:async';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/picker_orders_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/bloc/picker_report_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/picker_reports.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_products/products_page.dart';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_profile/profile_page.dart';
import 'package:ansarlogistics/components/custom_app_components/alert_dialogs.dart';
import 'package:ansarlogistics/components/custom_app_components/bottom_bar/custom_bottom_bar_picker.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/network/network_service_status.dart';
import 'package:ansarlogistics/utils/permission_service.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class PickerDashboardPage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  const PickerDashboardPage({Key? key, required this.serviceLocator})
    : super(key: key);

  @override
  State<PickerDashboardPage> createState() => _PickerDashboardPageState();
}

class _PickerDashboardPageState extends State<PickerDashboardPage> {
  StreamSubscription? networkSubscription;
  StreamSubscription? subscription;
  StreamSubscription? navSubscription;
  int pageIndex = -1;
  int selectedIndex = 0;

  @override
  void dispose() {
    if (subscription != null) {
      subscription!.cancel();
    }
    if (networkSubscription != null) {
      networkSubscription!.cancel();
    }
    super.dispose();
  }

  init() async {
    subscription = context.gTradingApiGateway.networkStreamController.stream
        .listen((event) {
          if (event.contains("session timeout")) {
            log("session timeout from sp request");
            sessionTimeOutBottomSheet(
              context: context,
              inputWidget: SessionOutBottomSheet(
                onTap: () async {
                  await logout(context);
                },
              ),
            );
          }
        });
  }

  Future<void> requestPermissions() async {
    // await Permission.location.request();
    // await Permission.locationWhenInUse.request();
    // await Permission.locationAlways.request();
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    // if (!await Permission.microphone.isGranted) {
    //   await Permission.microphone.request();
    // }
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    // await Permission.phone.request();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        bool returnVal = false;

        if (selectedIndex == 0) {
          await showAlertDilogue(
            context: context,
            content: "Do you want to exit the app?",
            positiveButtonName: "Yes",
            negativeButtonName: "No",
            onPositiveButtonClick: () {
              if (mounted) {
                setState(() {
                  returnVal = true;
                });
              }
              Navigator.of(context).pop();
              // Navigator.of(context).pop();
            },
            onNegativeButtonClick: () {
              if (mounted) {
                setState(() {
                  returnVal = false;
                });
              }
              Navigator.of(context).pop();
            },
          );
        } else {}
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: customColors().backgroundPrimary,
          ),
        ),
        backgroundColor: customColors().backgroundPrimary,
        bottomNavigationBar: CustomBottomNavigationBarPicker(
          selectedIndex: selectedIndex,
          context: context,
          onTap: (int value) {
            BlocProvider.of<NavigationCubit>(context).updateWatchList(value);
            setState(() {
              selectedIndex = value;
            });
          },
        ),
        body: BlocConsumer<NavigationCubit, NavigationState>(
          builder: (context, state) {
            if (state is WatchlistIndexState) {
              return IndexedStack(
                index: state.index,
                children: [
                  BlocProvider(
                    create:
                        (context) => PickerOrdersCubit(
                          context.gTradingApiGateway,
                          context,
                          PostRepositories(
                            PostService(widget.serviceLocator, context),
                          ),
                        ),
                    child: PickerOrdersPage(),
                  ),
                  // PickerOrdersPage(),
                  BlocProvider(
                    create:
                        (context) => PickerReportCubit(
                          context: context,
                          serviceLocator: widget.serviceLocator,
                        ),
                    child: PickerReports(),
                  ),
                  ProductsPage(),
                  ProfilePage(serviceLocator: widget.serviceLocator),
                ],
              );
            }
            return Container();
          },
          listener: (context, state) {
            if (state is WatchlistIndexState) {
              switch (state.index) {
                case 0:
                  selectedIndex = 0;
                  break;
                case 1:
                  selectedIndex = 1;
                  break;
                case 2:
                  selectedIndex = 2;
                  break;
                case 3:
                  selectedIndex = 3;
                  break;
              }
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
