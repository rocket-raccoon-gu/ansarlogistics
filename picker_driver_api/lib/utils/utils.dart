import 'dart:developer';

import 'package:flutter/foundation.dart';

serviceSend(String name) {
  if (kDebugMode) {
    log("ServiceSend " + name);
  }
}

serviceSendError(String name) {
  if (kDebugMode) {
    log("ServiceSendError " + name, error: "name");
  }
}
