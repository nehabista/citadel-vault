import 'dart:async';

import 'package:citadel_password_manager/app.dart';
import 'package:citadel_password_manager/data/services/api/pocketbase_service.dart';
import 'package:citadel_password_manager/logic/controllers/auth_controller.dart';
import 'package:citadel_password_manager/utils/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MainClassInitialize {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Get.putAsync(() => PocketBaseService().init());
    await DependencyInjection.init();
    Get.put(AuthController());

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    runApp(const CItadelVaultApp());
  }
}

Future<void> main() async {
  await MainClassInitialize.initialize();
}
