import 'dart:io';

import 'package:ansarlogistics/navigations/navigation.dart';
import 'package:ansarlogistics/services/crash_analytics.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/user_settings.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ServiceLocator serviceLocator;
  final BuildContext context;
  String misc3 = "";

  LoginCubit(this.context, {required this.serviceLocator})
    : super(LoginLoading()) {
    getUserCode();
  }

  getUserCode() async {
    if (await PreferenceUtils.preferenceHasKey("userCode")) {
      String id =
          UserController().userName =
              (await PreferenceUtils.getDataFromShared("userCode")) ?? "";
      String val = await PreferenceUtils.getDataFromShared("password") ?? "";

      if (id != "" && val != "") {
        // Validate the encrypted password

        try {
          // String pass = decryptStringForUser(val, keyVal(id));
          if (val != "") {
            if (await sendLoginRequest(
              context: context,
              userId: id,
              password: val,
            )) {
              return;
            }
          } else {
            // Handle invalid password
            // print("Decrypted password is empty");
            if (!isClosed) emit(LoginInitial());
          }
        } catch (e) {
          // Handle decryption errors
          // print("Decryption failed: $e");
          if (!isClosed) emit(LoginInitial());
        }
      } else {
        // Handle empty or invalid data
        // print("Invalid or empty userCode or password");
        if (!isClosed) emit(LoginInitial());
      }
    } else {
      if (!isClosed) emit(LoginInitial());
    }
    // }
    // if (!isClosed) emit(LoginInitial());
  }

  Future<bool> sendLoginRequest({
    required context,
    required String userId,
    required String password,
  }) async {
    UserController().userName = userId;
    UserController().passWord = password;
    if (!isClosed) {
      if (state is LoginInitial) {
        emit((state as LoginInitial).copyWith(loading: true));
      }
    }

    try {
      DateTime requestTime = DateTime.now();

      context.gNavigationService.openSalesDashboard(context);

      //   await FirebaseMessaging.instance.getToken().then((value) async {
      //     UserController.userController.devicetoken = value!;
      //     // print("devicetoken =" + value);
      //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //     // print('Running on ${androidInfo.model}');
      //     // print("Running on ${androidInfo.id}");
      //     // print("Running on ${androidInfo.device}");
      //     // print("Running on ${androidInfo.brand}");

      //     final info = await PackageInfo.fromPlatform();

      //     // final String serverkey = await getAccessToken();

      //     await PreferenceUtils.storeDataToShared("devicetoken", value);

      //     Map<String, dynamic> data = {
      //       "deviceid": androidInfo.id,
      //       "device": androidInfo.device,
      //       "model": androidInfo.model,
      //     };

      //     LoginResponse loginResponse = await serviceLocator.tradingApi
      //         .loginRequest(
      //           userId: userId,
      //           password: password,
      //           token: value,
      //           bearertoken: "",
      //           appversion: "2.0.16",
      //         );
      //     DateTime responseTime = DateTime.now();

      //     if (loginResponse.success) {
      //       UserController.userController.profile = loginResponse.profile;

      //       UserController().app_token = loginResponse.token;

      //       await PreferenceUtils.storeDataToShared(
      //         "usertoken",
      //         loginResponse.token,
      //       );

      //       await PreferenceUtils.storeDataToShared(
      //         "userid",
      //         loginResponse.profile.id.toString(),
      //       );

      //       // // Encrypt the password
      //       // String encryptedHex = encryptStringForUser(password, key);

      //       await PreferenceUtils.storeDataToShared("password", password);

      //       updateUserController(
      //         sessionKey: "",
      //         userId: userId,
      //         username: userId,
      //       );

      //       swithcnavigate(context, loginResponse.profile.role.toString());

      //       // context.gNavigationService.openPickerWorkspacePage(context);

      //       showSnackBar(
      //         context: context,
      //         snackBar: showSuccessDialogue(message: "Login Success....!"),
      //       );

      //       return true;
      //     } else {
      //       showSnackBar(
      //         context: context,
      //         snackBar: showErrorDialogue(errorMessage: "Login Failed"),
      //       );
      //       return false;
      //     }
      //   });
      // } on SocketException {
      //   if (state is LoginInitial) {
      //     emit(
      //       (state as LoginInitial).copyWith(error: "Network connectivity error"),
      //     );
      //   } else {
      //     emit(LoginInitial(errorMessage: "Network connectivity error"));
      //   }
      //   return false;
    } catch (e, trace) {
      fatalError(e.toString(), trace, "login processing failed");
      if (state is LoginInitial) {
        emit((state as LoginInitial).copyWith(error: e.toString()));
      } else {
        emit(LoginInitial(errorMessage: e.toString()));
      }
    }
    return false;
  }
}

Future<String> getAccessToken() async {
  try {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "ah-market-5ab28",
      "private_key_id": "5642c3e3db6707f875af8cba7e78cead92b1b5a1",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDggC67Xcdnvaiq\nC+NhKu/BEvnOv8RUodobf+Gtt2qnnhVv3TM1aqfXQX2qaYHG75fggeqXHieNTKyp\n1pIONnCmWYhk8zGT/a8byD0bZt4E+FBGln4gcXYdWzYdyO+qUPsZFYRDAW9/yd5p\n03qpAo1nO4/HKtEbgpwh1CyEj1ZWVavMxSBNrzpQLZttjLp0OPAeCrv3UciK5xid\nOvKqPaUorYxGKgJjaaXh0ly1rRfWuQwzuH1XoyIp+S8m1/nEbPR5W85/Qv2KvI9m\nTiXq8M7PJ1jne41ypwHYoKwqgGy8nfK7FIocQCiH1SwVCfVX1bYYOW/F9TndKPV+\n2wNaVRTlAgMBAAECggEABIn67HjMUDNR2f6UwJFJj7uYqb7Gd88nNaV7prf0qsJo\nbwxQ1Hx4u8JgwIWb7kkRMAAYb7uF4Wi5fNMnGL9lPnTpdTufYBjK6nK0OLlbrEv6\nz86LoaI4fZiG1BxoPYKNtkCoJs/zJ1byxGyffxPtvXaepPToezOEN9NOQ0H/7h/2\n9wnHW6g0t/vAay8q2ne+zYmuKB3LuTl5MPuD083Pk5KXwqYrxHKrW0G7nxdJvxzA\ngdAH1KXWqN3SXXVH2XRmZfFqUlYhCMqTTRnRscqXoMN6J2DYvUz/1hbYH2jynLVV\nNg9BVCQPtcc9U3ENOEzSb7zxCrz246/YB7FhSFEm6QKBgQDvy4pnHj6rtgBD4mKn\nLh+mCellYl9HKeCuW7XHyp1/fgv+ueYPqALUXkR+92j0X8PawCwtb1qxFvWtjXz/\ncfpj/sQpAOERbeAjU6dNPxi5RbYqQyOhQgAbfwWoCrH6Y2hp2vesFypykCW3aP7Z\nM/eQ6nfFowkE4xfIUCuRgDGUPQKBgQDvrAyPqMIlnYsOn0LvmFCd/bVM7vKFw3cK\nale2QzqrhedaGHX2WjER7vwo8l9UIuwFRX1aSP1Nb+f/BcFQzbs+Z7VXck2Xj4o3\np0NhOuyLbpSaPDwiSSuMUkGuYgwkmIVnptBmw92ikV+vOAAwvOdMHjvy8GDbFnpc\nYPS9eTSFyQKBgQCxJK3jq4Ykl1juzSiP1BTxNdVDXj6AdcFTTNCm/VkIO/dkf7Qi\n0Lz2YYU8Pk08ahpnWRvJnL9kn09ynFlA49RTVntWxx19IKw5rKyk9f2vsH34Do0d\nrYIizd1B3FTKYfFacbYRXTOwWihiq5/ImQlD9tHwIJajE5gYFJF69TarCQKBgG0e\negGWJf6WQc+Adys6v8mOz1Kdn9GC8tnNHO4gob+iEXkVle95lMnDcw75eqmF1Mt5\nnd7TSHBPOOKQoDk30b5R3WBY7DbK5XT9NFI6T6QTzpiCQCakBa23bawFe93Vizdr\n3YpMNsZjRZsy9fM6rlwbj9PF2XMmQsN4aTUyz9TxAoGBAOxe2pEjjvgR4Ll58lsP\nVq9K+u9HKAVDM32feUm+KIDILy5bPTb+6HjEcsEHF567GuCga3wciX9wk7Cxh8ko\nFkTJuUdDORqVDOkYgw2hl+bcOSKQsuem2ve13vmdq2mKhF4x8DGM4lckegvxUWyM\nziqB8bQJYo8UedjNiX99gR6W\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-a6zp5@ah-market-5ab28.iam.gserviceaccount.com",
      "client_id": "107685861698938940303",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-a5zp5%40ah-market-5ab28.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database",
    ];

    // Create auth client
    final authClient = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Get access credentials
    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      authClient,
    );

    authClient.close();

    return credentials.accessToken.data;
  } catch (e, stackTrace) {
    // Log the error with more details
    print('Error obtaining access token: $e');
    print('Stack trace: $stackTrace');

    // Check if it's a clock skew error
    if (e.toString().contains('invalid_grant') &&
        e.toString().contains('JWT')) {
      print(
        'This might be a clock synchronization issue. '
        'Please check your device time is correct.',
      );
    }

    // Re-throw the error to be handled by the calling function
    rethrow;
  }
}

updateUserController({
  required String sessionKey,
  required String userId,
  required String username,
}) {
  // UserController().sessionKey = sessionKey;
  UserController().userName = username;
  UserController.userController.userShortName =
      username
          .split(" ")
          .map((el) => el.substring(0, 1))
          .join("")
          .toUpperCase();
  UserController.userController.userShortName = UserController
      .userController
      .userShortName
      .substring(
        0,
        UserController.userController.userShortName.length > 1 ? 2 : 1,
      );
  UserController().userName = userId;
  updateUserData(username: username, userId: userId);
}

updateUserData({required String username, required String userId}) async {
  await PreferenceUtils.storeDataToShared("userCode", userId);
  if (!(await PreferenceUtils.preferenceHasKey(userId))) {
    UserSettings.userSettings.fromJson({});
    await PreferenceUtils.storeDataToShared(
      userId,
      UserSettings.userSettings.toJsonString(),
    );
  }
  String? userData = await PreferenceUtils.getDataFromShared(userId);
  UserSettings.userSettings.fromJsonString(userData!);
  UserSettings.userSettings.userPersonalSettings.username = username;
  UserSettings.userSettings.userPersonalSettings.username = userId;
  PreferenceUtils.storeDataToShared(
    userId,
    UserSettings.userSettings.toJsonString(),
  );
}
