import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_signup/bloc/signup_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_signup/bloc/signup_page_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //
  //
  //

  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  TextEditingController contactnumberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController employeeidController = TextEditingController();

  TextEditingController vehiclenumController = TextEditingController();

  TextEditingController vehicletypeController = TextEditingController();

  TextEditingController emailidController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  File? idPhotoFile;
  File? numberPlatePhotoFile;

  final roles = ["Select Role", "Picker", "Driver", "Rider"];

  String role = "Select Role";

  String company = "Select Company";

  String shiftr = "08:00 AM - 06:00 PM";

  String fridr = "08:00 AM - 06:00 PM";

  String off = "Sunday";

  String? roleId;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  //   Future<void> pickIdPhoto() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //   );

  //   if (result != null) {
  //     setState(() {
  //       idPhotoFile = File(result.files.single.path!);
  //     });
  //   }
  // }

  // Future<void> pickNumberPlatePhoto() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //   );

  //   if (result != null) {
  //     setState(() {
  //       numberPlatePhotoFile = File(result.files.single.path!);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor('#F9FBFF'),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(183, 214, 53, 1),
        ),
      ),
      body: BlocBuilder<SignupPageCubit, SignupPageState>(
        builder: (context, state) {
          if (state is SignupPageLoadingState) {
            return Center(child: const CircularProgressIndicator());
          }

          if (state is SignupPageErrorState) {
            return Text('Error: ${state.message}');
          }

          if (state is SignupPageInitialState) {
            employeeidController = TextEditingController(
              text: context.read<SignupPageCubit>().currentid,
            );

            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.0,
                        color: customColors().backgroundTertiary,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          context.gNavigationService.back(context);

                          //
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 23,
                          color: HexColor("#A3A3A3"),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Picker/Driver Registration",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //
                //
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Please fill up the form below to complete signup.",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Regular,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 12.0,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: idFormKey,
                        child: Column(
                          children: [
                            //
                            //
                            // enter your name
                            CustomTextFormField(
                              context: context,
                              controller: nameController,
                              fieldName: "Name",
                              hintText: "Enter your name here",
                              validator: Validator.defaultValidator,
                            ),
                            //
                            //
                            // enter your contact number
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Contact number")]),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 15.0,
                                          horizontal: 5.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              customColors().backgroundPrimary,
                                          border: Border.all(
                                            color: customColors().fontTertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5.0,
                                          ),
                                        ),
                                        child: Text("+974"),
                                      ),
                                      Expanded(
                                        child: CustomTextFormField(
                                          context: context,
                                          controller: contactnumberController,
                                          fieldName: "",
                                          keyboardType: TextInputType.phone,
                                          hintText: "Enter your phone number",
                                          minimumValueLimit: 9,
                                          validator:
                                              Validator.minimumValueLimit,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //
                            //
                            // Upload ID Photo
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Upload ID Photo")]),
                                  Row(
                                    children: [
                                      // Expanded(
                                      //   child: ElevatedButton(
                                      //     onPressed: pickIdPhoto,
                                      //     child: Text(idPhotoFile == null ? "Select ID Photo" : "ID Photo Selected"),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  if (idPhotoFile != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("File: ${idPhotoFile!.path}"),
                                    ),
                                ],
                              ),
                            ),

                            //
                            //
                            // enter your password
                            CustomTextFormField(
                              context: context,
                              controller: passwordController,
                              fieldName: "Password",
                              hintText: "Enter your password",
                              obscureIcon: true,
                              validator: Validator.password,
                            ),
                            //
                            //
                            // employee id
                            // CustomTextFormField(
                            //   context: context,
                            //   controller: employeeidController,
                            //   fieldName: "Employee ID",
                            //   hintText: "Enter your employee ID",
                            //   validator: Validator.defaultValidator,
                            //   enabled: false,
                            // ),
                            //
                            //
                            // emailid
                            CustomTextFormField(
                              context: context,
                              controller: emailidController,
                              fieldName: "Email ID",
                              hintText: "Enter your email ID",
                              keyboardType: TextInputType.emailAddress,
                              validator: Validator.none,
                            ),
                            //
                            //
                            //
                            // address
                            CustomTextFormField(
                              context: context,
                              controller: addressController,
                              fieldName: "Address",
                              hintText: "Enter your Address",
                              keyboardType: TextInputType.streetAddress,
                              // validator: Validator.defaultValidator,
                            ),
                            //
                            //
                            // role
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Role")]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color:
                                                    customColors().fontTertiary,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                items:
                                                    roles
                                                        .map(
                                                          (
                                                            e,
                                                          ) => DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: e,
                                                            child: Text(
                                                              e.toString(),
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyM_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                value: role,
                                                onChanged: (value) {
                                                  if (value != "Select Role") {
                                                    setState(() {
                                                      role =
                                                          value
                                                              .toString(); // Update the dropdown value
                                                      roleId = getUserType(
                                                        value.toString(),
                                                      ); // Store the mapped value
                                                    });
                                                  } else {
                                                    showSnackBar(
                                                      context: context,
                                                      snackBar: showErrorDialogue(
                                                        errorMessage:
                                                            "Please Select Role..!",
                                                      ),
                                                    );
                                                  }
                                                },
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

                            //
                            //
                            // company
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  const Row(children: [Text("Company")]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color:
                                                    customColors().fontTertiary,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Text(
                                                  "Select Company",
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.BodyM_Bold,
                                                    color:
                                                        FontColor.FontPrimary,
                                                  ),
                                                ),
                                                value:
                                                    company == null ||
                                                            company ==
                                                                "Select Company"
                                                        ? null
                                                        : company,
                                                items: [
                                                  // Default option
                                                  DropdownMenuItem<String>(
                                                    value: null,
                                                    child: Text(
                                                      "Select Company",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  // Company options - accessed directly from your existing bloc state
                                                  ...state.companyList.map((
                                                    company,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value:
                                                          company['name']
                                                              ?.toString(),
                                                      child: Text(
                                                        company['name']
                                                                ?.toString() ??
                                                            'Unknown',
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .BodyM_Bold,
                                                          color:
                                                              FontColor
                                                                  .FontPrimary,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                                onChanged: (
                                                  String? selectedValue,
                                                ) {
                                                  if (selectedValue == null) {
                                                    showSnackBar(
                                                      context: context,
                                                      snackBar: showErrorDialogue(
                                                        errorMessage:
                                                            "Please Select Company..!",
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  setState(() {
                                                    company = selectedValue;
                                                  });
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                          ),
                                                    ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                      maxHeight: 200,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                      ),
                                                    ),
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

                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 4.0),
                            //   child: Column(
                            //     children: [
                            //       Row(children: [Text("Company")]),
                            //       Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //           vertical: 12.0,
                            //         ),
                            //         child: Row(
                            //           children: [
                            //             Expanded(
                            //               child: Container(
                            //                 decoration: BoxDecoration(
                            //                   borderRadius: BorderRadius.circular(
                            //                     5.0,
                            //                   ),
                            //                   border: Border.all(
                            //                     color:
                            //                         customColors().fontTertiary,
                            //                   ),
                            //                 ),
                            //                 child: DropdownButtonHideUnderline(
                            //                   child: DropdownButton2(
                            //                     items:
                            //                         BlocProvider.of<
                            //                               SignupPageCubit
                            //                             >(context).companylist
                            //                             .map(
                            //                               (e) => DropdownMenuItem<
                            //                                 String
                            //                               >(
                            //                                 value: e['name'],
                            //                                 child: Text(
                            //                                   e['name']
                            //                                       .toString(),
                            //                                   style: customTextStyle(
                            //                                     fontStyle:
                            //                                         FontStyle
                            //                                             .BodyM_Bold,
                            //                                     color:
                            //                                         FontColor
                            //                                             .FontPrimary,
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             .toList(),
                            //                     value: company,
                            //                     onChanged: (value) {
                            //                       if (value != "Select Company") {
                            //                         setState(() {
                            //                           company =
                            //                               value
                            //                                   .toString(); // Update the dropdown value
                            //                           // Store the mapped value
                            //                         });
                            //                       } else {
                            //                         showSnackBar(
                            //                           context: context,
                            //                           snackBar: showErrorDialogue(
                            //                             errorMessage:
                            //                                 "Please Select Company..!",
                            //                           ),
                            //                         );
                            //                       }
                            //                     },
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            //
                            //
                            // regular shift
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Regular Shifts")]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color:
                                                    customColors().fontTertiary,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                      maxHeight: 250.0,
                                                    ),
                                                items:
                                                    regular_shifts
                                                        .map(
                                                          (
                                                            e,
                                                          ) => DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: e,
                                                            child: Text(
                                                              e.toString(),
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyM_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                value: shiftr,
                                                onChanged: (value) {
                                                  setState(() {
                                                    shiftr = value!;
                                                  });
                                                },
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
                            //
                            //
                            // friday shift
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Friday Shifts")]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color:
                                                    customColors().fontTertiary,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                      maxHeight: 250,
                                                    ),
                                                items:
                                                    friday_shifts
                                                        .map(
                                                          (
                                                            e,
                                                          ) => DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: e,
                                                            child: Text(
                                                              e.toString(),
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyM_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                value: fridr,
                                                onChanged: (value) {
                                                  setState(() {
                                                    fridr = value!;
                                                  });
                                                },
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

                            //
                            //
                            // Day Off
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Row(children: [Text("Day Off")]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color:
                                                    customColors().fontTertiary,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                      maxHeight: 250,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 2.0,
                                                          ),
                                                    ),
                                                items:
                                                    dayoffs
                                                        .map(
                                                          (
                                                            e,
                                                          ) => DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: e,
                                                            child: Text(
                                                              e.toString(),
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyM_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                value: off,
                                                onChanged: (value) {
                                                  setState(() {
                                                    off = value!;
                                                  });
                                                },

                                                // buttonHeight: 50,
                                                // itemHeight: 40,
                                                // dropdownMaxHeight: 200, // Set max height for the dropdown
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

                            //
                            //
                            // Vehicle Number
                            CustomTextFormField(
                              context: context,
                              controller: vehiclenumController,
                              fieldName: "Vehicle Number",
                              hintText: "Enter your vehicle number",
                            ),
                            //
                            //
                            // Vehicle Type
                            CustomTextFormField(
                              context: context,
                              controller: vehicletypeController,
                              fieldName: "Vehicle Type",
                              hintText: "Enter your vehicle type",
                            ),
                            //
                            //
                            //
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Container(); //
        },
      ),
      bottomNavigationBar: SizedBox(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 5.0,
                      ),
                      child: BasketButton(
                        onpress: () async {
                          if (idFormKey.currentState!.validate()) {
                            log("ok");

                            if (role == "Select Role") {
                              showSnackBar(
                                context: context,
                                snackBar: showErrorDialogue(
                                  errorMessage: "Please Select Role",
                                ),
                              );
                            } else if (company == "Select Company") {
                              showSnackBar(
                                context: context,
                                snackBar: showErrorDialogue(
                                  errorMessage: "Please Select Company...!",
                                ),
                              );
                            } else {
                              final info = await PackageInfo.fromPlatform();

                              // _packageInfo = info;

                              Map<String, dynamic> driverData = {
                                "employee_id":
                                    context.read<SignupPageCubit>().currentid,
                                "name": nameController.text.toString(),
                                "email": emailidController.text.toString(),
                                "mobile_number":
                                    contactnumberController.text.toString(),
                                "password": passwordController.text.toString(),
                                "address": addressController.text.toString(),
                                "role": roleId,
                                "driver_type": company,
                                "regular_shift_time": shiftr.toString(),
                                "friday_shift_time": fridr.toString(),
                                "day_off": off.toString(),
                                "vehicle_number":
                                    vehiclenumController.text.toString(),
                                "vehicle_type":
                                    vehicletypeController.text.toString(),
                                "app_version": _packageInfo.version,
                              };

                              BlocProvider.of<SignupPageCubit>(
                                context,
                              ).signUpDriver(driverData);
                            }
                          }
                        },
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                        text: "Register",
                        bgcolor: Color.fromRGBO(183, 214, 53, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
