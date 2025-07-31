import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controllers/home_page_controller.dart';
import '../../../logic/local_storage.dart';
import '../auth/auth_page.dart';
import 'onbarding_page.dart';

class OnboardRouter extends StatelessWidget {
  const OnboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: LocalStorageSharedPref.getOnboardingStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          if (snapshot.data!) {
            Get.put(HomePageController(), permanent: true);
          }
          return snapshot.data! ? const AuthScreen() : const OnbardingScreen();
        } else {
          return const OnbardingScreen();
        }
      },
    );
  }
}
