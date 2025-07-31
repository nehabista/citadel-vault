import 'package:citadel_password_manager/gen/assets.gen.dart';
import 'package:citadel_password_manager/presentation/pages/auth/login_screen.dart';
import 'package:citadel_password_manager/presentation/pages/auth/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../logic/controllers/auth_controller.dart';
import '../../../routing/route_names.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AuthScreen   build called');
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: const Color.fromARGB(255, 130, 152, 195),
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
              ),
              backgroundColor: Colors.white,
              leadingWidth: 60.w,
              toolbarHeight: 6.h,
              shadowColor: Colors.black38,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  2.w.widthBox,
                  Image.asset(
                    Assets.images.citadelLogo.path,
                    height: 3.8.h,
                  ).px(2),
                  const SizedBox(width: 8),
                  Text(
                    'Citadel Vault',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  color: const Color(0xff4D4DCD),
                  icon: const Icon(Bootstrap.info_circle),
                  onPressed: () async {
                    Get.toNamed(AppRoutes.HOME);
                    // await showSignupInfoDialog(context);
                  },
                ).px(6),
              ],
              centerTitle: false,
              elevation: 3,
            ),
            resizeToAvoidBottomInset: true,
            body: Material(
              type: MaterialType.transparency,
              elevation: 8,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: const Offset(1, 0),
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: PhysicalModel(
                  color: Colors.white,
                  elevation: 8,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  shadowColor: Colors.black38,
                  child: Obx(() {
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<int>(
                            padding: const EdgeInsets.only(
                              top: 4,
                              bottom: 4,
                              left: 6,
                              right: 6,
                            ),
                            children: {
                              0: 'Login'.text.bold.isIntrinsic.make(),
                              1: 'Sign Up'.text.bold.isIntrinsic.make(),
                            },
                            groupValue: controller.sliding.value,
                            onValueChanged: (int? value) {
                              if (value != null) {
                                controller.changeSlidingValue(value);
                              }
                            },
                          ),
                        ).pOnly(top: 15, bottom: 8).px(30),
                        if (controller.sliding.value == 0) ...[LoginScreen()],
                        if (controller.sliding.value == 1) ...[SignUpScreen()],
                      ],
                    );
                  }),
                ),
              ),
            ).px(16).pOnly(top: 30),
          ),
        );
      },
    );
  }
}
