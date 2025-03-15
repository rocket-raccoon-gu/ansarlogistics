import 'package:ansarlogistics/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

initializeFirebase() async {
  await Firebase.initializeApp();
}

disableCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
}

bool getCrashAnalyticsStat() =>
    FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;

forceCrash() => FirebaseCrashlytics.instance.crash();

enableCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
}

firebaseLog({required String msg, String trace = ""}) =>
    FirebaseCrashlytics.instance.log("$msg [$trace]");

fatalError(String error, dynamic trace, [String reason = "fatal error"]) =>
    FirebaseCrashlytics.instance.recordError(
      error,
      trace,
      reason: reason,
      fatal: true,
    );

nonFatalError(
  String error,
  dynamic trace, [
  String reason = "non fatal error",
]) => FirebaseCrashlytics.instance.recordError(error, trace, reason: reason);
