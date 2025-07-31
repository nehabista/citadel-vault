import 'package:citadel_password_manager/presentation/pages/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomePageController extends GetxController {

  static HomePageController get to => Get.find();
  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void onNavigationItemTap(int index) {
    _selectedIndex.value = index;

  }

  final RxList<Widget> _pages =
      [
        const DashBoardPage(),
        const Center(child: Text('Citadel Locksmith')),
        const Center(child: Text('Citadel Settings')),
        const Center(child: Text('Citadel Vault')),
      ].obs;

  List<Widget> get pages => _pages;
}
