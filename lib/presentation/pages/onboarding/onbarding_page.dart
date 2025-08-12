// File: lib/presentation/pages/onboarding/onbarding_page.dart
import 'package:citadel_password_manager/presentation/pages/onboarding/onboarding_widget.dart'
    show OnboardingPage;
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../gen/assets.gen.dart';
import '../../../logic/local_storage.dart';
import '../../../routing/app_router.dart';

class OnbardingScreen extends StatelessWidget {
  const OnbardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Future<void> completeOnboarding() async {
      await LocalStorageSharedPref.saveOnboardingStatus(true);
      await Future.delayed(const Duration(milliseconds: 1));
      if (context.mounted) context.go(AppRoutes.login);
    }

    return OnBoardingSlider(
      imageHorizontalOffset: screenWidth * 0.02,
      centerBackground: true,
      indicatorAbove: false,
      headerBackgroundColor: Colors.white,
      indicatorPosition: screenHeight * 0.03,
      onFinish: completeOnboarding,
      addController: true,
      controllerColor: Colors.black,
      finishButtonText: 'Secure My Account Now',
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: Colors.black,
        elevation: 2,
      ),
      skipTextButton: const Text('Skip'),
      trailingFunction: completeOnboarding,
      trailing: const Text('Join Us Now!'),
      middle: Text(
        'Citadel Vault',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: screenWidth * 0.042,
          fontWeight: FontWeight.bold,
        ),
      ),
      background: [
        SizedBox(
          height: screenHeight * 0.4,
          width: screenWidth * 0.8,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Lottie.asset(
              fit: BoxFit.contain,
              Assets.animations.shieldCitadel.path,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.6,
          width: screenWidth * 0.8,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Lottie.asset(
              fit: BoxFit.contain,
              Assets.animations.devicesSyncCitadel.path,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.5,
          width: screenWidth * 0.8,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Lottie.asset(
              fit: BoxFit.contain,
              Assets.animations.faceIdCitadel.path,
            ),
          ),
        ),
      ],
      totalPage: 3,
      speed: 1.8,
      pageBodies: [
        OnboardingPage(
          topSpacing: screenHeight * 0.33,
          title: "Your Digital Fortress, Fortified",
          description:
              "Welcome to Citadel. We use state-of-the-art, client-side encryption to ensure that your passwords and private data are for your eyes only. Not even we can see them.",
        ),
        OnboardingPage(
          topSpacing: screenHeight * 0.5,
          title: "Seamlessly Synced Across Devices!",
          description:
              "Your digital life doesn't stop at one screen. Access your secure vault from your phone, tablet, or desktop. Your data stays in sync, everywhere.",
        ),
        OnboardingPage(
          topSpacing: screenHeight * 0.5,
          title: "Unlock Your World, Instantly",
          description:
              "No more forgotten passwords. With powerful password generation and secure autofill, you can access your accounts effortlessly and securely every single time.",
        ),
      ],
    );
  }
}
