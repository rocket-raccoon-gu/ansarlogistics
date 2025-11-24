import 'dart:convert';
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

import '../../../firebase_configs/fcm_service.dart';
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

        String role = await PreferenceUtils.getDataFromShared("role") ?? "";

        final profileJsonString = await PreferenceUtils.getDataFromShared(
          "profiledata",
        );

        if (profileJsonString != null) {
          // Convert JSON string back to Map
          // Convert JSON string back to Map
          final profileMap =
              jsonDecode(profileJsonString) as Map<String, dynamic>;

          // Create Profile object from Map
          final profile = Profile.fromJson(profileMap);

          UserController().profile = profile;
        }

        swithcnavigate(context, role);

        // try {
        //   // String pass = decryptStringForUser(val, keyVal(id));
        //   if (val != "") {
        //     if (await sendLoginRequest(
        //       context: context,
        //       userId: id,
        //       password: val,
        //     )) {
        //       return;
        //     }
        //   } else {
        //     // Handle invalid password
        //     // print("Decrypted password is empty");
        //     if (!isClosed) emit(LoginInitial());
        //   }
        // } catch (e) {
        //   // Handle decryption errors
        //   // print("Decryption failed: $e");
        //   if (!isClosed) emit(LoginInitial());
        // }
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

      await FirebaseMessaging.instance.getToken().then((value) async {
        UserController.userController.devicetoken = value!;
        // print("devicetoken =" + value);
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // print('Running on ${androidInfo.model}');
        // print("Running on ${androidInfo.id}");
        // print("Running on ${androidInfo.device}");
        // print("Running on ${androidInfo.brand}");

        final info = await PackageInfo.fromPlatform();

        // final String serverkey = await getAccessToken();

        await PreferenceUtils.storeDataToShared("devicetoken", value);

        Map<String, dynamic> data = {
          "deviceid": androidInfo.id,
          "device": androidInfo.device,
          "model": androidInfo.model,
        };

        LoginResponse loginResponse = await serviceLocator.tradingApi
            .loginRequest(
              userId: userId,
              password: password,
              token: value,
              bearertoken: "",
              appversion: info.version,
            );
        DateTime responseTime = DateTime.now();

        if (loginResponse.success) {
          UserController.userController.profile = loginResponse.profile;

          UserController().app_token = loginResponse.token;

          await PreferenceUtils.storeDataToShared(
            "usertoken",
            loginResponse.token,
          );

          await PreferenceUtils.storeDataToShared(
            "userid",
            loginResponse.profile.id.toString(),
          );

          await PreferenceUtils.storeDataToShared(
            "role",
            loginResponse.profile.role.toString(),
          );

          await PreferenceUtils.storeDataToShared(
            "profiledata",
            json.encode(loginResponse.profile.toJson()),
          );

          // // Encrypt the password
          // String encryptedHex = encryptStringForUser(password, key);

          await PreferenceUtils.storeDataToShared("password", password);

          updateUserController(
            sessionKey: "",
            userId: userId,
            username: userId,
          );

          swithcnavigate(context, loginResponse.profile.role.toString());

          // context.gNavigationService.openPickerWorkspacePage(context);

          showSnackBar(
            context: context,
            snackBar: showSuccessDialogue(message: "Login Success....!"),
          );

          return true;
        } else {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Login Failed"),
          );
          return false;
        }
      });
    } on SocketException {
      if (state is LoginInitial) {
        emit(
          (state as LoginInitial).copyWith(error: "Network connectivity error"),
        );
      } else {
        emit(LoginInitial(errorMessage: "Network connectivity error"));
      }
      return false;
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
      "private_key_id": "9850d082026a221a64499bce1a7c3c753f51806a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCwU9yhJPQ2Fusr\noSRKYwRM2fKgUW9piJAcH1s7gzMtdwewv4f6aCJVYCG+w5Fe04IYogEN0rcmml5o\nZvx/mJtjyySIsNZaFHr3hw6ZSkfRWPOH++nD4J52Dd5bd4gXM5Cnd5obIS5g9O98\nLN/qX13QbwUJOwNTiB7WcesiS10AC0Ij+v2clgXzwcjoa6qmlN/BS4ebAwhIVl9p\n2B2HzumQvhvaNPcbkD37FM35/0WqydF1HWFFANKlhTT9hG4fNkwjk7rr1+d9oSXv\nT7sXJSln15vQMUaRmWEbTSJTa8plljQP6FoD/CcnlbIAJwHDTlaRlnL5g+PtNHP+\neQQ+N17hAgMBAAECggEABMR4Xd8x3v+wDdglEwGkm/8qvdjZ0vAF78wNaM66Mg0K\noeXPKMR1mi/tAFC0GWI4CCUNiNNvz4fDYfNX5CDK4cVm3a8Z/+nswwzNe/RL0bju\nmQ3aUxPGNmGssjXUBzGQxDsPU/4J4vCjGYJymZkIwFzCFXmZSaIaba37P4GrYuz/\nggahxBQr0YiI15Ih7TuDYpRMkOT6hFULBx5QkNZd7+fIzsPpOoCevL+JLafDkGgL\nqcRmlOWkttIXtrowMZYELeWanXnIdfdhAUAt//wP58FaFtkBpydmoJaC5ZQofoGA\nufc17Q+/11Qe+/nsVkZNaS4Vkx9nNtUW6+Yeg8d5OQKBgQDabqRzj9/g0LjYfo6h\nk0Hb/XwYaj68TNA9BT3540HhXswW9KkG0We1bT1zCGL6bPR0STraX3ohWZo5Atnm\nGYX9vBaXnVi02wlmpWiM6VdDMqW3C2/5kNMZ/rJZVFbjgTVTMvZ4RZQqm6LMGsjF\nkscjdCGzkRYsUU8g/P5v3QfF6QKBgQDOp2TurkPxKEHWWd3g6dhbt6wKo7TkpT80\n0e5AAn36rXlOJ8MLPYhmEXJa7ymu4ptm9mJxhQ1LkA2CIuE/9PKZXLPlvl6nA6El\n7Ip1clFQMvRbzCbJcwVPxpTBb0fwQMylS+7n2b8WcC3rDYbiEGYc1rN9il7xwWD2\nYFA7PhMeOQKBgQCBoPnNbwvQ0m1wZaLltot2L7eukZbLjtZh8DN4kequAeEimm2Z\nEzr1y2+VTdvXfEOSo0bfA5xqIE/LF6sSyADhtPa/YWycYATzOqSSQ4Q659q6h3ob\nZFwzaBiVtNyfxTVNO8hTVg95PcXeVOLjhZjSrH+3nhnHkTVhgWLKJiUPyQKBgQDG\n60KwrXYg8EtPdXmqQe5NeuNT6nj5jkblJR5c5wk0/z7BCG0qqLRe63RUK9rHyMEl\nvwzLkPNXRPZ7ye9gjPvou98+ypx5z3iS9Lnii4PR2vp0UnMTfnAidlhCSkfI79cN\nVaZF7seNZbYNiBvKB1cDc3ea5FK4Cxi2j8cq/3mPoQKBgQCdnKJo6yn7baUoLGvg\n0plX8hqgnsKxdn29h7muscB1DQDwPlczBRY90VkfHsliSFNCv3JOIioYv6FB+lc5\nixvhbVdx1n9b2niyYeUsUnr686bltkInQvQQ2wPr9k7KVb4tdy8Ifsp6VhCGdiyX\ncwNxCyd1qIksvErXGMY0XWUVVg==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-a6zp5@ah-market-5ab28.iam.gserviceaccount.com",
      "client_id": "107685861698938940303",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-a6zp5%40ah-market-5ab28.iam.gserviceaccount.com",
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
