import 'package:citadel_password_manager/logic/controllers/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../gen/assets.gen.dart';
import '../widgets/bottom_nav_item.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 60.w,
            toolbarHeight: 6.h,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                2.w.widthBox,
                Image.asset(
                  Assets.images.citadelLogo.path,
                  height: 3.8.h,
                ).px(2),
                const SizedBox(width: 8),
                Obx(() {
                  final index = controller.selectedIndex;
                  final title =
                      index == 1
                          ? 'Citadel LocksmithX'
                          : index == 2
                          ? 'Citadel Settings'
                          : 'Citadel Vault';
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
            centerTitle: false,
            actions: [
              Obx(() {
                return controller.selectedIndex == 0
                    ? Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C91F2),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(93, 28, 146, 242),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-1, -1),
                              blurRadius: 1,
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            debugPrint('+ New button tapped');
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: -1,
                              vertical: -1,
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink();
              }),
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Container(
              height: 7.5.h,
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.1,
                      red: 0,
                      green: 0,
                      blue: 0,
                    ),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: BottomNavItem(
                        icon: Bootstrap.shield_lock,
                        label: 'Citadel',
                        isSelected: controller.selectedIndex == 0,
                        onTap: () => controller.onNavigationItemTap(0),
                      ),
                    ),
                    Expanded(
                      child: BottomNavItem(
                        icon: Bootstrap.file_lock,
                        label: 'Locksmith',
                        isSelected: controller.selectedIndex == 1,
                        onTap: () => controller.onNavigationItemTap(1),
                      ),
                    ),
                    Expanded(
                      child: BottomNavItem(
                        icon: Bootstrap.gear,
                        label: 'Settings',
                        isSelected: controller.selectedIndex == 2,
                        onTap: () => controller.onNavigationItemTap(2),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          body: Obx(() => controller.pages[controller.selectedIndex]),
        );
      },
    );
  }
}
