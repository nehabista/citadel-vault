import 'package:citadel_password_manager/routing/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../logic/controllers/auth_controller.dart';

class VerificationPendingScreen extends StatelessWidget {
  final String email;
  const VerificationPendingScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Get.theme.primaryColor,
              ),
              30.heightBox,
              'Check Your Inbox'.text
                  .size(28)
                  .bold
                  .align(TextAlign.center)
                  .make(),
              15.heightBox,
              'We have sent a verification link to:'.text
                  .size(16)
                  .align(TextAlign.center)
                  .gray500
                  .make(),
              5.heightBox,
              email.text.size(16).bold.align(TextAlign.center).make(),
              40.heightBox,
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.AUTH),
                child: 'Go to Login'.text.make(),
              ),
              20.heightBox,
              TextButton(
                onPressed: () => authController.resendVerificationEmail(email),
                child: 'Resend Verification Email'.text.make(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
