import 'dart:async';
import 'dart:developer';

import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_orders/bloc/driver_orders_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_orders/driver_orders_page.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/driver_reports.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_summery/driver_summery_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_profile/profile_page.dart';
import 'package:ansarlogistics/components/custom_app_components/bottom_bar/custom_bottom_bar_driver.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/network/network_service_status.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class DriverDashboardPage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  const DriverDashboardPage({super.key, required this.serviceLocator});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
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
            // showAlertDilogue(
            //     context: context,
            //     content:
            //         "Session expired, or you have loged in from a different location.",
            //     positiveButtonName: "Relogin",
            //     onPositiveButtonClick: () async {
            //       await logout(context);
            //     });
          }
        });
  }

  // Future<void> requestPermissions() async {
  //   await Permission.activityRecognition.request();
  //   await Permission.location.request();
  //   await Permission.locationWhenInUse.request();
  //   await Permission.locationAlways.request();

  //   // await Permission.microphone.request();
  //   await Permission.notification.request();
  //   await Permission.phone.request();
  //   await Permission.storage.request();
  //   await Permission.camera.request();
  // }

  Future<void> requestPermissions() async {
    try {
      // Request permissions one by one with proper error handling

      // Location permissions
      await handlePermission(Permission.location, context);
      await handlePermission(Permission.locationWhenInUse, context);
      await handlePermission(Permission.locationAlways, context);

      // Other permissions
      await handlePermission(Permission.activityRecognition, context);
      await handlePermission(Permission.notification, context);
      await handlePermission(Permission.phone, context);
      await handlePermission(Permission.storage, context);
      await handlePermission(Permission.camera, context);
    } catch (e, stackTrace) {
      log('Permission request error: $e', stackTrace: stackTrace);
      if (kReleaseMode) {
        // In production, you might want to silently fail or show a user-friendly message
      } else {
        // In debug, show the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    networkSubscription = NetworkStatusService.networkStatusController.stream
        .listen((NetworkStatus status) {
          log("NETWORK : $status");
          if (status == NetworkStatus.Online) {
            log("NETWORK : Inernet connection restored");
            ScaffoldMessenger.of(context).showSnackBar(
              showSuccessDialogue(message: "Inernet connection restored"),
            );
          } else if (status == NetworkStatus.Offline) {
            log("NETWORK : Inernet connection lost");
            ScaffoldMessenger.of(context).showSnackBar(
              showErrorDialogue(errorMessage: "Inernet connection lost"),
            );
          }
        });

    navSubscription = context
        .read<NavigationCubit>()
        .adcontroller
        .stream
        .listen((event) {
          pageIndex = event.currIndex;
        });

    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        log("log");
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(
              elevation: 0,
              backgroundColor: customColors().backgroundPrimary,
            ),
          ),
          bottomNavigationBar: CustomBottomBarDriver(
            context: context,
            selectedIndex: selectedIndex,
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
                          (context) => DriverOrdersPageCubit(
                            context.gTradingApiGateway,
                            context,
                            PostRepositories(
                              PostService(widget.serviceLocator, context),
                            ),
                          ),
                      child: DriverOrdersPage(),
                    ),
                    BlocProvider(
                      create:
                          (context) => DriverReportCubit(
                            context: context,
                            serviceLocator: widget.serviceLocator,
                          ),
                      child: DriverReportsPage(),
                    ),
                    DriverSummeryPage(),
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
                  case 4:
                    selectedIndex = 0;
                    break;
                }
                setState(() {});
              }
            },
          ),
        ),
      ),
    );
  }
}
