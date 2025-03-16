import 'dart:async';
import 'dart:developer';

import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_orders/bloc/driver_orders_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_orders/bloc/driver_orders_page_state.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/list_item/driver_order_list_item.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/custom_app_bar.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class DriverOrdersPage extends StatefulWidget {
  const DriverOrdersPage({super.key});

  @override
  State<DriverOrdersPage> createState() => _DriverOrdersPageState();
}

class _DriverOrdersPageState extends State<DriverOrdersPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

  final _searchcontroller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  StreamController<void> fcmRefreshStream = StreamController<void>.broadcast();

  StreamSubscription<void>? fcmRefreshSubScription;

  List<Order>? orderitems = [];

  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        BlocProvider.of<DriverOrdersPageCubit>(context).loadPosts(
          1,
          driverstatuslist[UserController().selectedindex]['status'],
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // if (message. .toString().contains("assigned")) {
      onMessageRecieved(message.notification!.title.toString());
      // }
    });

    getusercheck();
    DateTime current = DateTime.now();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool isRequestingPermission = false; // Prevent multiple requests

  getusercheck() async {
    if (isRequestingPermission)
      return; // Stop if a request is already in progress
    isRequestingPermission = true;

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // Check current permission status before requesting
    NotificationSettings settings =
        await firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      // Only request permission if not yet determined
      settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // Handle different authorization statuses
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User permission not granted");
    }

    isRequestingPermission = false;
  }

  void onMessageRecieved(String title) async {
    BlocProvider.of<DriverOrdersPageCubit>(context).loadPosts(0, "");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('App Resumed From Background----------------------------------');
      log('App Resumed From Background----------------------------------');

      // if (Platform.isAndroid && UserController.userController.firsttime) {
      //   UserController.userController.firsttime = false;
      // } else if (Platform.isAndroid &&
      //     !UserController.userController.firsttime) {
      await Future.delayed(Duration(seconds: 2));

      Timer.periodic(Duration(seconds: 30), (tim) async {
        await Permission.location.isGranted.then((value) async {
          if (value) {
            try {
              Position position = await Geolocator.getCurrentPosition();

              // log("location ${position.latitude},${position.longitude} ...${DateTime.now()}");

              await PreferenceUtils.storeDataToShared(
                "userlat",
                position.latitude.toString(),
              );

              await PreferenceUtils.storeDataToShared(
                "userlong",
                position.longitude.toString(),
              );

              UserController.userController.locationlatitude =
                  position.latitude.toString();

              UserController.userController.locationlongitude =
                  position.longitude.toString();
            } catch (e) {}
          }
        });
      });

      await Permission.location.isGranted.then((value) async {
        if (value) {
          try {
            Position position = await Geolocator.getCurrentPosition();

            // log("location ${position.latitude},${position.longitude} ...${DateTime.now()}");

            await PreferenceUtils.storeDataToShared(
              "userlat",
              position.latitude.toString(),
            );

            await PreferenceUtils.storeDataToShared(
              "userlong",
              position.longitude.toString(),
            );

            UserController.userController.locationlatitude =
                position.latitude.toString();

            UserController.userController.locationlongitude =
                position.longitude.toString();

            BlocProvider.of<DriverOrdersPageCubit>(context).updatelocation(
              position.latitude.toString(),
              position.longitude.toString(),
            );
          } catch (e) {
            log("error updating in location");
          }
        }
      });

      // Simulating a delay for the splash screen
      //   RestartWidget.restartApp(context);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    //     CustomAppBar(
    //       onpressfind: () async {
    //         await BlocProvider.of<DriverOrdersPageCubit>(context)
    //             .updateseekorder();
    //       },
    //       ispicker: false,
    //       isload: isloading,
    //     ),
    //     const SizedBox(height: 14),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 10.0),
    //       child: CustomSearchField(
    //         onSearch: (val) {
    //           BlocProvider.of<DriverOrdersPageCubit>(context).updatesearchorder(
    //               UserController().orderitems, val.toString().toUpperCase());
    //         },
    //         controller: _searchcontroller,
    //         searchFormKey: _ordersearchFormKey,
    //         keyboardType: TextInputType.text,
    //         onFilter: () {
    //           // customShowModalBottomSheet(
    //           //     context: context,
    //           //     inputWidget: FilterByType(
    //           //         onTapSubmit: (int indexed) {
    //           //           BlocProvider.of<DriverOrdersPageCubit>(context)
    //           //               .loadPosts(0, statuslist[indexed]['status']);

    //           //           context.gNavigationService.back(context);
    //           //         },
    //           //         selectedindex: UserController().selectedindex,
    //           //         statuslist: statuslist));
    //         },
    //       ),
    //     ),
    //     BlocConsumer<DriverOrdersPageCubit, DriverOrdersPageState>(
    //         listener: (context, state) {
    //       if (state is DriverOrderSeekLoadingState) {
    //         setState(() {
    //           isloading = true;
    //         });
    //       } else {
    //         setState(() {
    //           isloading = false;
    //         });
    //       }
    //     }, builder: (context, state) {
    //       if (state is DriverPageLoadingState) {
    //         orderitems = state.oldpost;
    //         isloading = true;
    //       } else if (state is DriverPageLoadedState) {
    //         orderitems = state.posts;
    //         // UserController.userController.orderitems = orderitems!;
    //         isloading = false;
    //       }
    //       if (state is DriverPageLoadingState && state.isFirstFetch) {
    //         return const Expanded(
    //             child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [LoadingIndecator()],
    //         ));
    //       } else if (state is DriverPageLoadingState && orderitems!.isEmpty) {
    //         // ignore: curly_braces_in_flow_control_structures
    //         return const Expanded(
    //             child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [LoadingIndecator()],
    //         ));
    //       } else if (state is DriverOrderSeekLoadingState) {
    //         return Expanded(
    //             child: Column(
    //           children: [
    //             Lottie.asset(
    //                 'assets/lottie_files/Animation - 1733906326255.json'),
    //             Text(
    //               "Finding Orders...!",
    //               style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
    //             )
    //           ],
    //         ));
    //       } else {
    //         return Expanded(
    //           child: RefreshIndicator(
    //               child: Stack(
    //                 children: [
    //                   Column(
    //                     children: [
    //                       if (orderitems!.isEmpty)
    //                         const EmptyBox()
    //                       else
    //                         Expanded(
    //                             child: Padding(
    //                           padding:
    //                               const EdgeInsets.symmetric(horizontal: 12.0),
    //                           child: SingleChildScrollView(
    //                             controller: scrollController,
    //                             child: Column(
    //                               children: [
    //                                 Padding(
    //                                   padding: const EdgeInsets.all(8.0),
    //                                   child: Row(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       Image.asset(
    //                                         'assets/route.png',
    //                                         height: 38,
    //                                       ),
    //                                       Expanded(
    //                                         child: BasketButton(
    //                                             bgcolor: customColors().green3,
    //                                             text: "View My Route",
    //                                             onpress: () async {
    //                                               context.gNavigationService
    //                                                   .openOrderRoutesPage(
    //                                                       context,
    //                                                       arg: {
    //                                                     'data': orderitems
    //                                                   });
    //                                             },
    //                                             textStyle: customTextStyle(
    //                                                 fontStyle:
    //                                                     FontStyle.BodyL_Bold,
    //                                                 color: FontColor.White)),
    //                                       )
    //                                     ],
    //                                   ),
    //                                 ),
    //                                 ListView.builder(
    //                                     controller: scrollController,
    //                                     itemCount: orderitems!.length +
    //                                         (isloading ? 1 : 0),
    //                                     shrinkWrap: true,
    //                                     physics: NeverScrollableScrollPhysics(),
    //                                     itemBuilder: (context, index) {
    //                                       if (index < orderitems!.length) {
    //                                         return DriverOrderListItem(
    //                                           orderResponseItem:
    //                                               orderitems![index],
    //                                           index: index,
    //                                           reschedulesuccess: () {
    //                                             toastification.show(
    //                                                 backgroundColor:
    //                                                     customColors().green3,
    //                                                 autoCloseDuration:
    //                                                     const Duration(
    //                                                         seconds: 3),
    //                                                 title: Text(
    //                                                   "Order Rescheduled..!",
    //                                                   style: customTextStyle(
    //                                                       fontStyle: FontStyle
    //                                                           .BodyL_Bold,
    //                                                       color:
    //                                                           FontColor.White),
    //                                                 ));

    //                                             BlocProvider.of<
    //                                                         DriverOrdersPageCubit>(
    //                                                     context)
    //                                                 .loadPosts(0, "");
    //                                           },
    //                                         );
    //                                       } else {
    //                                         Timer(
    //                                             const Duration(
    //                                                 milliseconds: 30), () {
    //                                           scrollController.jumpTo(
    //                                               scrollController.position
    //                                                   .maxScrollExtent);
    //                                         });
    //                                         return const LoadingIndecator();
    //                                       }
    //                                     }),
    //                               ],
    //                             ),
    //                           ),
    //                         ))
    //                     ],
    //                   )
    //                 ],
    //               ),
    //               onRefresh: () async {
    //                 BlocProvider.of<DriverOrdersPageCubit>(context)
    //                     .loadPosts(0, "");
    //               }),
    //         );
    //       }
    //     }),
    //   ],
    // );

    return Scaffold(
      body: BlocConsumer<DriverOrdersPageCubit, DriverOrdersPageState>(
        listener: (context, state) {
          if (state is DriverOrderSeekLoadingState) {
            if (mounted) {
              setState(() {
                isloading = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isloading = false;
              });
            }
          }
        },
        builder: (context, state) {
          final items = (state is DriverPageLoadedState) ? state.posts : [];

          if (state is DriverPageLoadingState) {
            orderitems = state.oldpost;
            isloading = true;
          } else if (state is DriverPageLoadedState) {
            orderitems = state.posts;
            // UserController.userController.orderitems = orderitems!;
            isloading = false;
          }

          return Column(
            children: [
              CustomAppBar(
                onpressfind: () async {
                  await BlocProvider.of<DriverOrdersPageCubit>(
                    context,
                  ).updateseekorder();
                },
                ispicker: false,
                isload: isloading,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CustomSearchField(
                  onSearch: (val) {
                    BlocProvider.of<DriverOrdersPageCubit>(
                      context,
                    ).updatesearchorder(
                      UserController().orderitems,
                      val.toString().toUpperCase(),
                    );
                  },
                  controller: _searchcontroller,
                  searchFormKey: _ordersearchFormKey,
                  keyboardType: TextInputType.text,
                  onFilter: () {},
                ),
              ),
              if (!(state is DriverOrderSeekLoadingState))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/route.png', height: 38),
                      Expanded(
                        child: BasketButton(
                          bgcolor: customColors().green3,
                          text: "View My Route",
                          onpress: () async {
                            context.gNavigationService.openOrderRoutesPage(
                              context,
                              arg: {'data': orderitems},
                            );
                          },
                          textStyle: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(),
              if (state is DriverPageLoadingState && state.isFirstFetch)
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                )
              else if (state is DriverPageLoadingState && orderitems!.isEmpty)
                // ignore: curly_braces_in_flow_control_structures
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                )
              else if (state is DriverOrderSeekLoadingState)
                Expanded(
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/lottie_files/Animation - 1733906326255.json',
                      ),
                      Text(
                        "Finding Orders...!",
                        style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<DriverOrdersPageCubit>(
                        context,
                      ).loadPosts(0, "");
                    },
                    child:
                        orderitems!.isEmpty
                            ? SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        "No Orders Found..!",
                                        style: customTextStyle(
                                          fontStyle:
                                              FontStyle.HeaderXS_SemiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  if (index < orderitems!.length) {
                                    return DriverOrderListItem(
                                      orderResponseItem: orderitems![index],
                                      index: index,
                                      reschedulesuccess: () {
                                        toastification.show(
                                          backgroundColor:
                                              customColors().green3,
                                          autoCloseDuration: const Duration(
                                            seconds: 3,
                                          ),
                                          title: Text(
                                            "Order Rescheduled..!",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyL_Bold,
                                              color: FontColor.White,
                                            ),
                                          ),
                                        );

                                        BlocProvider.of<DriverOrdersPageCubit>(
                                          context,
                                        ).loadPosts(0, "");
                                      },
                                    );
                                  } else {
                                    Timer(const Duration(milliseconds: 30), () {
                                      scrollController.jumpTo(
                                        scrollController
                                            .position
                                            .maxScrollExtent,
                                      );
                                    });
                                    return const LoadingIndecator();
                                  }
                                },
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
