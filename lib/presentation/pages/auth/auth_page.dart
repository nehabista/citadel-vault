// File: lib/presentation/pages/auth/auth_page.dart
import 'package:citadel_password_manager/gen/assets.gen.dart';
import 'package:citadel_password_manager/presentation/pages/auth/login_screen.dart';
import 'package:citadel_password_manager/presentation/pages/auth/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(255, 130, 152, 195),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
          backgroundColor: Colors.white,
          leadingWidth: screenWidth * 0.6,
          toolbarHeight: screenHeight * 0.06,
          shadowColor: Colors.black38,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.asset(
                  Assets.images.citadelLogo.path,
                  height: screenHeight * 0.038,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Citadel Vault',
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                color: const Color(0xff4D4DCD),
                icon: const Icon(Bootstrap.info_circle),
                onPressed: () {},
              ),
            ),
          ],
          centerTitle: false,
          elevation: 3,
        ),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .copyWith(top: 30),
          child: Material(
            type: MaterialType.transparency,
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(1, 0),
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
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 8, left: 30, right: 30),
                      child: SizedBox(
                        width: double.infinity,
                        child: CupertinoSlidingSegmentedControl<int>(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            left: 6,
                            right: 6,
                          ),
                          children: const {
                            0: Text('Login',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            1: Text('Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          },
                          groupValue: authState.slidingIndex,
                          onValueChanged: (int? value) {
                            if (value != null) {
                              notifier.changeSlidingValue(value);
                            }
                          },
                        ),
                      ),
                    ),
                    if (authState.slidingIndex == 0) const LoginScreen(),
                    if (authState.slidingIndex == 1) const SignUpScreen(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
