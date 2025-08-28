import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/cs_tool_tip_board.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/sheet_button.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/customer_details_tab.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/driver_customer_details_tab.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/picker_customer_details_tab.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_status_history/status_history.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:toastification/toastification.dart';

class CustomerDetailsSheet extends StatefulWidget {
  final Function()? onTapClose;
  final ServiceLocator serviceLocator;
  final OrderNew orderResponseItem;

  CustomerDetailsSheet({
    Key? key,
    required this.onTapClose,
    required this.serviceLocator,
    required this.orderResponseItem,
  }) : super(key: key);

  @override
  State<CustomerDetailsSheet> createState() => _CustomerDetailsSheetState();
}

class _CustomerDetailsSheetState extends State<CustomerDetailsSheet>
    with SingleTickerProviderStateMixin {
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();
  late TabController tabController;
  static const platform = MethodChannel(
    'com.ahqa.pickerdriver.ahpickerdriver.call_recorder/recording',
  );
  bool isRecording = false;
  String? filePath;

  CallLogs c1 = CallLogs();

  bool enablecancelrequest = false;

  bool sendcancelreq = false;

  bool enableholdrequest = false;

  bool enablecsnotanswrrequest = false;

  // late SIPUAHelper sipuaHelper;

  String _registrationStatus = "Not Registered";

  String _statusMessage = "Not Registered";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      setState(() {});
    });

    // sipuaHelper = SIPUAHelper();
    // sipuaHelper.addSipUaHelperListener(this);
    // registerWith3CX();
  }

  // registerWith3CX() {
  //   final UaSettings settings = UaSettings();
  //   settings.webSocketUrl = 'wss://ansar.3cx.ae:5001/ws'; // WebSocket URL
  //   settings.uri = 'sip:203@ansar.3cx.ae'; // Your SIP URI (3CX extension)
  //   settings.authorizationUser = '203'; // 3CX extension number
  //   settings.password = 'Ansar@9999'; // SIP/3CX account password
  //   settings.displayName = 'Haris'; // Display name for calls
  //   settings.transportType = TransportType.WS;
  //   settings.userAgent = 'Flutter SIP UA';
  //   // Fix: Set transportType explicitly
  //   settings.transportType = TransportType.WS;

  //   sipuaHelper.start(settings);
  //   sipuaHelper.addSipUaHelperListener(this);
  // }

  Future<void> startRecording() async {
    try {
      final String? result = await platform.invokeMethod('startRecording');
      setState(() {
        isRecording = true;
        filePath = result;
      });
      // print('Recording started: $filePath');
    } on PlatformException catch (e) {
      // print("Failed to start recording: ${e.message}");
    }
  }

  Future<void> stopRecording() async {
    try {
      await platform.invokeMethod('stopRecording');
      setState(() {
        isRecording = false;
      });
      // print('Recording stopped');
    } on PlatformException catch (e) {
      // print("Failed to stop recording: ${e.message}");
    }
  }

  Future<void> uploadRecording() async {
    if (filePath != null) {
      File file = File(filePath!);
      try {
        await FirebaseStorage.instance
            .ref(
              'call_recordings/${widget.orderResponseItem.subgroupIdentifier}.mp3',
            )
            .putFile(file, SettableMetadata(contentType: 'audio/mpeg'));
        // print('File uploaded successfully');
      } catch (e) {
        // print('Error uploading file: $e');
      }
    }
  }

  Future<void> handleCall() async {
    // await startRecording(); // Start recording
    try {
      // sipuaHelper.call('sip:203@ansar.3cx.ae');
      c1.call(widget.orderResponseItem.customer!.phone.toString(), () async {
        // await Future.delayed(Duration(seconds: 10)); // Simulate call duration
        // // Stop recording after call ends
        // await stopRecording();
        // await uploadRecording(); // Upload after stopping recording
      });
    } catch (e) {
      // print("Error during call: $e");
      // await stopRecording(); // Ensure recording stops if there's an error
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    // if (sipuaHelper.registerState.state == RegistrationStateEnum.REGISTERED) {
    //   await sipuaHelper.call(
    //       'sip:$phoneNumber@ansar.3cx.ae'); // Add `@domain` for SIP dialing.
    //   setState(() {
    //     _statusMessage = "Calling $phoneNumber...";
    //   });
    // } else {
    //   setState(() {
    //     _statusMessage = "Not Registered. Cannot make calls.";
    //   });

    //   log(_statusMessage);
    // }
  }

  @override
  void dispose() {
    // sipuaHelper.removeSipUaHelperListener(this);
    // sipuaHelper.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: customColors().backgroundPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: idFormKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(onTap: widget.onTapClose, child: Icon(Icons.close)),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      unselectedLabelColor: customColors().dodgerBlue,
                      controller: tabController,
                      tabs: [
                        Tab(
                          child: TranslatedText(
                            text: "Info",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                        Tab(
                          child: TranslatedText(
                            text: "Comments",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // CustomerDetailsTab(
                    //   orderResponseItem: widget.orderResponseItem,
                    //   enablecancelrequest: enablecancelrequest,
                    //   enableholdrequest: enableholdrequest,
                    //   enablecsnotaanswer: enablecsnotanswrrequest,
                    // ),
                    // if (UserController().profile.role == "2" ||
                    //     UserController().profile.role == "3")
                    //   DriverCustomerDetailsTab(
                    //     orderResponseItem: widget.orderResponseItem,
                    //   )
                    // else
                    PickerCustomerDetailsTab(
                      orderResponseItem: widget.orderResponseItem,
                    ),
                    StatusHistory(
                      serviceLocator: widget.serviceLocator,
                      orderResponseItem: widget.orderResponseItem,
                    ),
                  ],
                ),
              ),

              // if (enablecancelrequest)
              //   Row(
              //     children: [
              //       Expanded(
              //         child: BasketButton(
              //           bgcolor: customColors().carnationRed,
              //           textStyle: customTextStyle(
              //             fontStyle: FontStyle.BodyL_Bold,
              //             color: FontColor.White,
              //           ),
              //           text: "Send Cancel Request",
              //           loading: sendcancelreq,
              //           onpress: () async {
              //             if (UserController().cancelreason !=
              //                     "Please Select Reason" &&
              //                 UserController().cancelreason !=
              //                     "Other Reasons") {
              //               setState(() {
              //                 sendcancelreq = true;
              //               });

              //               showSnackBar(
              //                 context: context,
              //                 snackBar: showSuccessDialogue(
              //                   message: "status updating....!",
              //                 ),
              //               );

              //               final resp = await context.gTradingApiGateway
              //                   .updateMainOrderStat(
              //                     orderid:
              //                         widget
              //                             .orderResponseItem
              //                             .subgroupIdentifier,
              //                     orderstatus: "cancel_request",
              //                     comment:
              //                         "${UserController().profile.name.toString()} (${UserController().profile.empId}) is requested cancel the order for ${UserController().cancelreason.toString()}",
              //                     userid: UserController().profile.id,
              //                     latitude:
              //                         UserController
              //                             .userController
              //                             .locationlatitude,
              //                     longitude:
              //                         UserController
              //                             .userController
              //                             .locationlongitude,
              //                   );

              //               try {
              //                 if (resp.statusCode == 200) {
              //                   toastification.show(
              //                     backgroundColor: customColors().secretGarden,
              //                     context: context,
              //                     autoCloseDuration: const Duration(seconds: 5),
              //                     title: Text(
              //                       "Requested For Cancel...!",
              //                       style: customTextStyle(
              //                         fontStyle: FontStyle.BodyL_Bold,
              //                         color: FontColor.White,
              //                       ),
              //                     ),
              //                   );

              //                   UserController().cancelreason =
              //                       "Please Select Reason";

              //                   Navigator.of(
              //                     context,
              //                   ).popUntil((route) => route.isFirst);

              //                   if (UserController
              //                           .userController
              //                           .profile
              //                           .role ==
              //                       "2") {
              //                     context.gNavigationService
              //                         .openDriverDashBoardPage(context);
              //                   } else {
              //                     context.gNavigationService
              //                         .openPickerWorkspacePage(context);
              //                   }
              //                 } else {
              //                   setState(() {
              //                     sendcancelreq = false;
              //                   });

              //                   toastification.show(
              //                     backgroundColor: customColors().carnationRed,
              //                     context: context,
              //                     autoCloseDuration: const Duration(seconds: 5),
              //                     title: Text(
              //                       "Send Request Failed Please Try Again...!",
              //                       style: customTextStyle(
              //                         fontStyle: FontStyle.BodyL_Bold,
              //                         color: FontColor.White,
              //                       ),
              //                     ),
              //                   );
              //                 }
              //               } catch (e) {
              //                 setState(() {
              //                   sendcancelreq = false;
              //                 });

              //                 toastification.show(
              //                   backgroundColor: customColors().carnationRed,
              //                   context: context,
              //                   autoCloseDuration: const Duration(seconds: 5),
              //                   title: Text(
              //                     "Send Request Failed Please Try Again...!",
              //                     style: customTextStyle(
              //                       fontStyle: FontStyle.BodyL_Bold,
              //                       color: FontColor.White,
              //                     ),
              //                   ),
              //                 );
              //               }
              //             } else {
              //               showSnackBar(
              //                 context: context,
              //                 snackBar: showErrorDialogue(
              //                   errorMessage: "Please Update Reason...!",
              //                 ),
              //               );
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   )
              // else if (enableholdrequest)
              //   Row(
              //     children: [
              //       Expanded(
              //         child: BasketButton(
              //           bgcolor: customColors().mattPurple,
              //           textStyle: customTextStyle(
              //             fontStyle: FontStyle.BodyL_Bold,
              //             color: FontColor.White,
              //           ),
              //           text: 'Send Hold Request',
              //           loading: sendcancelreq,
              //           onpress: () async {
              //             if (UserController().cancelreason !=
              //                 "Please Select Reason") {
              //               setState(() {
              //                 sendcancelreq = true;
              //               });

              //               showSnackBar(
              //                 context: context,
              //                 snackBar: showSuccessDialogue(
              //                   message: "status updating....!",
              //                 ),
              //               );

              //               final resp = await context.gTradingApiGateway
              //                   .updateMainOrderStat(
              //                     orderid:
              //                         widget
              //                             .orderResponseItem
              //                             .subgroupIdentifier,
              //                     orderstatus: "holded",
              //                     comment:
              //                         "${UserController().profile.name.toString()} (${UserController().profile.empId}) was holded the order for ${UserController().cancelreason.toString()}",
              //                     userid: UserController().profile.id,
              //                     latitude:
              //                         UserController
              //                             .userController
              //                             .locationlatitude,
              //                     longitude:
              //                         UserController
              //                             .userController
              //                             .locationlongitude,
              //                   );

              //               if (resp.statusCode == 200) {
              //                 toastification.show(
              //                   backgroundColor: customColors().secretGarden,
              //                   context: context,
              //                   autoCloseDuration: const Duration(seconds: 5),
              //                   title: Text(
              //                     "Order is On Hold",
              //                     style: customTextStyle(
              //                       fontStyle: FontStyle.BodyL_Bold,
              //                       color: FontColor.White,
              //                     ),
              //                   ),
              //                 );

              //                 UserController().cancelreason =
              //                     "Please Select Reason";

              //                 Navigator.of(
              //                   context,
              //                 ).popUntil((route) => route.isFirst);

              //                 if (UserController.userController.profile.role ==
              //                     "2") {
              //                   context.gNavigationService
              //                       .openDriverDashBoardPage(context);
              //                 } else {
              //                   context.gNavigationService
              //                       .openPickerWorkspacePage(context);
              //                 }
              //               } else {
              //                 setState(() {
              //                   sendcancelreq = false;
              //                 });

              //                 toastification.show(
              //                   backgroundColor: customColors().carnationRed,
              //                   context: context,
              //                   autoCloseDuration: const Duration(seconds: 5),
              //                   title: Text(
              //                     "Send Request Failed Please Try Again...!",
              //                     style: customTextStyle(
              //                       fontStyle: FontStyle.BodyL_Bold,
              //                       color: FontColor.White,
              //                     ),
              //                   ),
              //                 );
              //               }
              //             } else {
              //               // showSnackBar(
              //               //     context: context,
              //               //     snackBar: showErrorDialogue(
              //               //         errorMessage: "Please Fill The Reason..."));
              //               toastification.show(
              //                 backgroundColor: customColors().carnationRed,
              //                 context:
              //                     context, // optional if you use ToastificationWrapper
              //                 title: Text('Please Update The Reason...!'),
              //                 autoCloseDuration: const Duration(seconds: 5),
              //               );
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   )
              // else if (enablecsnotanswrrequest)
              //   Row(
              //     children: [
              //       Expanded(
              //         child: BasketButton(
              //           bgcolor: customColors().carnationRed,
              //           textStyle: customTextStyle(
              //             fontStyle: FontStyle.BodyL_Bold,
              //             color: FontColor.White,
              //           ),
              //           text: 'Customer Not Answering',
              //           onpress: () async {
              //             showSnackBar(
              //               context: context,
              //               snackBar: showSuccessDialogue(
              //                 message: "status updating....!",
              //               ),
              //             );

              //             final resp = await context.gTradingApiGateway
              //                 .updateMainOrderStat(
              //                   orderid:
              //                       widget.orderResponseItem.subgroupIdentifier,
              //                   orderstatus: "customer_not_answer",
              //                   comment:
              //                       "${UserController().profile.name.toString()} (${UserController().profile.empId}) was marked the order customer not answer",
              //                   userid: UserController().profile.id,
              //                   latitude:
              //                       UserController
              //                           .userController
              //                           .locationlatitude,
              //                   longitude:
              //                       UserController
              //                           .userController
              //                           .locationlongitude,
              //                 );

              //             if (resp.statusCode == 200) {
              //               toastification.show(
              //                 backgroundColor: customColors().secretGarden,
              //                 context: context,
              //                 autoCloseDuration: const Duration(seconds: 5),
              //                 title: Text(
              //                   "Order is on Customer Not Answer",
              //                   style: customTextStyle(
              //                     fontStyle: FontStyle.BodyL_Bold,
              //                     color: FontColor.White,
              //                   ),
              //                 ),
              //               );

              //               UserController().cancelreason =
              //                   "Please Select Reason";

              //               Navigator.of(
              //                 context,
              //               ).popUntil((route) => route.isFirst);

              //               if (UserController.userController.profile.role ==
              //                   "2") {
              //                 context.gNavigationService
              //                     .openDriverDashBoardPage(context);
              //               } else {
              //                 context.gNavigationService
              //                     .openPickerWorkspacePage(context);
              //               }
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   )
              // else
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       if (UserController.userController.profile.role == "2" &&
              //           widget.orderResponseItem.status == "on_the_way")
              //         Stack(
              //           children: [
              //             SheetButton(
              //               imagepath: 'assets/contact_btn.png',
              //               sheettext:
              //                   isRecording
              //                       ? 'Recording...'
              //                       : 'Contact \n Customer',
              //               onTapbtn: () async {
              //                 // await handleCall();
              //               },
              //             ),
              //             Positioned(
              //               child: CsToolTipBoard(
              //                 phone_num: widget.orderResponseItem.telephone,
              //                 onTap: () async {
              //                   await handleCall(); // Call and record
              //                   // await _makeCall('97450154119');
              //                 },
              //                 ordernum:
              //                     widget.orderResponseItem.subgroupIdentifier,
              //               ),
              //             ),
              //           ],
              //         )
              //       else if (UserController.userController.profile.role == "1")
              //         Stack(
              //           children: [
              //             SheetButton(
              //               imagepath: 'assets/contact_btn.png',
              //               sheettext:
              //                   isRecording
              //                       ? 'Recording...'
              //                       : 'Contact \n Customer',
              //               onTapbtn: () async {
              //                 // await handleCall();
              //               },
              //             ),
              //             Positioned(
              //               child: CsToolTipBoard(
              //                 phone_num: widget.orderResponseItem.telephone,
              //                 onTap: () async {
              //                   await handleCall(); // Call and record
              //                   // await _makeCall('97450154119');
              //                 },
              //                 ordernum:
              //                     widget.orderResponseItem.subgroupIdentifier,
              //               ),
              //             ),
              //           ],
              //         )
              //       else
              //         SheetButton(
              //           imagepath: 'assets/contact_btn.png',
              //           sheettext:
              //               isRecording
              //                   ? 'Recording...'
              //                   : 'Contact \n Customer',
              //           onTapbtn: () async {
              //             // await handleCall();
              //             toastification.show(
              //               backgroundColor: customColors().accent,
              //               title: Text("Please Mark On The Way...!"),
              //             );
              //           },
              //         ),
              //       SheetButton(
              //         imagepath: 'assets/cancel_req.png',
              //         sheettext: 'Cancel \n Request',
              //         onTapbtn: () {
              //           setState(() {
              //             enablecancelrequest = true;
              //           });
              //         },
              //       ),
              //       SheetButton(
              //         imagepath: 'assets/hold_req.png',
              //         sheettext: 'Hold \n Order',
              //         onTapbtn: () {
              //           setState(() {
              //             enableholdrequest = true;
              //           });
              //         },
              //       ),
              //       // Stack(
              //       //   children: [
              //       SheetButton(
              //         imagepath: 'assets/customer_ser.png',
              //         sheettext: 'Client not\n Answer',
              //         onTapbtn: () {
              //           setState(() {
              //             enablecsnotanswrrequest = true;
              //           });
              //         },
              //       ),
              //       // Positioned(
              //       //     child: CsToolTipBoard(
              //       //   phone_num: '+97460094446',
              //       //   ordernum: widget.orderResponseItem.subgroupIdentifier,
              //       //   onTap: () async {
              //       //     // await handleCall(); // Call and record
              //       //     c1.call('+97460094446', () {});
              //       //   },
              //       // )
              //       // )
              //       //   ],
              //       // )
              //     ],
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // void callStateChanged(Call call, CallState state) {
  //   print('Call State: ${state.state}');
  //   if (state.state == CallStateEnum.FAILED) {
  //     setState(() {
  //       _statusMessage = "Call Failed: ${state.cause}";
  //     });
  //   } else if (state.state == CallStateEnum.ENDED) {
  //     setState(() {
  //       _statusMessage = "Call Ended.";
  //     });
  //   }
  // }

  // @override
  // void onNewMessage(SIPMessageRequest msg) {
  //   // TODO: implement onNewMessage
  // }

  // @override
  // void onNewNotify(Notify ntf) {
  //   // TODO: implement onNewNotify
  // }

  // @override
  // void onNewReinvite(ReInvite event) {
  //   // TODO: implement onNewReinvite
  // }

  // @override
  // void registrationStateChanged(RegistrationState state) {
  //   setState(() {
  //     _statusMessage = state.state == RegistrationStateEnum.REGISTERED
  //         ? "Registered"
  //         : "Registration Failed: ${state.cause}";
  //   });
  // }

  // @override
  // void transportStateChanged(TransportState state) {
  //   // TODO: implement transportStateChanged
  //   log('Transport state: ${state.state}');
  // }
}
