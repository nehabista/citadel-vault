// screens/onboarding_screen.dart

import 'package:citadel_password_manager/presentation/pages/onboarding/onboarding_widget.dart'
    show OnboardingPage;
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../gen/assets.gen.dart';
import '../../../logic/local_storage.dart';
import '../../../routing/route_names.dart';

class OnbardingScreen extends StatelessWidget {
  const OnbardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return OnBoardingSlider(
          imageHorizontalOffset: 2.w,
          centerBackground: true,
          indicatorAbove: false,
          headerBackgroundColor: Colors.white,
          indicatorPosition: 3.h,
          onFinish: () async {
            await LocalStorageSharedPref.saveOnboardingStatus(true);
            await Future.delayed(
              const Duration(milliseconds: 1),
              () => Get.offAllNamed(AppRoutes.AUTH),
            );
          },
          addController: true,
          controllerColor: Colors.black,
          finishButtonText: 'Secure My Account Now',
          finishButtonStyle: const FinishButtonStyle(
            backgroundColor: Colors.black,
            elevation: 2,
          ),
          skipTextButton: const Text('Skip'),
          trailingFunction: () async {
            await LocalStorageSharedPref.saveOnboardingStatus(true);
            await Future.delayed(
              const Duration(milliseconds: 1),
              () => Get.offAllNamed(AppRoutes.AUTH),
            );
          },
          trailing: const Text('Join Us Now!'),
          middle:
              'Citadel Vault 🛡️'.text
                  .textStyle(
                    GoogleFonts.poppins(color: Colors.black, fontSize: 16.sp),
                  )
                  .bold
                  .make(),
          background: [
            SizedBox(
              height: 40.h,
              width: 80.w,
              child: Lottie.asset(
                fit: BoxFit.contain,
                Assets.animations.shieldCitadel.path,
              ).p(3.w),
            ),
            SizedBox(
              height: 60.h,
              width: 80.w,
              child: Lottie.asset(
                fit: BoxFit.contain,
                Assets.animations.devicesSyncCitadel.path,
              ).p(3.w),
            ),
            SizedBox(
              height: 50.h,
              width: 80.w,
              child: Lottie.asset(
                fit: BoxFit.contain,
                Assets.animations.faceIdCitadel.path,
              ).p(3.w),
            ),
          ],
          totalPage: 3,
          speed: 1.8,
          pageBodies: [
            OnboardingPage(
              topSpacing: 33.h,
              title: "Your Digital Fortress, Fortified",
              description:
                  "Welcome to Citadel. We use state-of-the-art, client-side encryption to ensure that your passwords and private data are for your eyes only. Not even we can see them.",
            ),
            OnboardingPage(
              topSpacing: 50.h,
              title: "Seamlessly Synced Across Devices!",
              description:
                  "Your digital life doesn't stop at one screen. Access your secure vault from your phone, tablet, or desktop. Your data stays in sync, everywhere.",
            ),
            OnboardingPage(
              topSpacing: 50.h,
              title: "Unlock Your World, Instantly",
              description:
                  "No more forgotten passwords. With powerful password generation and secure autofill, you can access your accounts effortlessly and securely every single time.",
            ),
          ],
        );
      },
    );
  }
}
