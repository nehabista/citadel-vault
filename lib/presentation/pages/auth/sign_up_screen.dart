import 'package:citadel_password_manager/logic/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../utils/validator.dart';
import '../../widgets/custom_button_with_splash.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    debugPrint('SignUpScreen build called');
    final AuthController controller = Get.find<AuthController>();
    return Form(
      key: _formKey,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: context.isMobile ? context.screenWidth * 0.9 : 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'auth_title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    "Let's get started!",
                    style: GoogleFonts.pacifico(
                      textStyle: const TextStyle(fontSize: 32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Hero(
                tag: 'auth_subtitle',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Your Secrets are Yours. Period.',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ).shimmer(
                    primaryColor: const Color.fromARGB(255, 0, 37, 55),
                    secondaryColor: const Color(0xff4D4DCD),
                    duration: 5.seconds,
                    showAnimation: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                autofocus: false,
                autofillHints: const [AutofillHints.name],
                controller: controller.nameControllerForSignUp,
                keyboardType: TextInputType.name,
                onSaved: (value) {
                  controller.nameControllerForSignUp.text = value!;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(15, 77, 77, 205),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  hintText: 'Enter Your Full Name',
                  filled: true,
                  prefixIcon: Icon(Bootstrap.person),
                  labelText: 'Full Name',
                ),
                validator: Validator().name,
              ),
              const SizedBox(height: 15),
              TextFormField(
                autofocus: false,
                autofillHints: const [AutofillHints.email],
                controller: controller.emailControllerForSignUp,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  controller.emailControllerForSignUp.text = value!;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(15, 77, 77, 205),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  hintText: 'Enter Your Email',
                  filled: true,
                  prefixIcon: Icon(Bootstrap.envelope),
                  labelText: 'Email',
                ),
                validator: Validator().email,
              ),
              const SizedBox(height: 15),
              Obx(() {
                return TextFormField(
                  obscureText: controller.passwordVisibility['signUp']!,
                  autofocus: false,
                  autofillHints: const [AutofillHints.password],
                  controller: controller.passwordControllerForSignUp,
                  onSaved: (value) {
                    controller.passwordControllerForSignUp.text = value!;
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    fillColor: Color.fromARGB(15, 77, 77, 205),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      controller.passwordVisibility['signUp']!
                          ? Bootstrap.lock
                          : Bootstrap.unlock,
                    ),
                    suffixIcon: Icon(
                      controller.passwordVisibility['signUp']!
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ).onTap(() {
                      controller.togglePasswordVisibility('signUp');
                    }),
                    hintText: 'Enter Account Password',
                    labelText: 'Password',
                  ),
                  validator: Validator().password,
                );
              }),
              const SizedBox(height: 15),
              Obx(() {
                return TextFormField(
                  obscureText: controller.passwordVisibility['master']!,
                  autofocus: false,
                  autofillHints: const [AutofillHints.password],
                  controller: controller.masterPasswordController,
                  onSaved: (value) {
                    controller.masterPasswordController.text = value!;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    fillColor: Color.fromARGB(15, 77, 77, 205),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      controller.passwordVisibility['master']!
                          ? Bootstrap.lock
                          : Bootstrap.unlock,
                    ),
                    suffixIcon: Icon(
                      controller.passwordVisibility['master']!
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ).onTap(() {
                      controller.togglePasswordVisibility('master');
                    }),
                    hintText: 'Enter Master Password',
                    labelText: 'Master Password',
                  ),
                  validator: Validator().password,
                );
              }),
              const SizedBox(height: 16),
              Hero(
                tag: 'auth_button',
                child: Obx(() {
                  return !controller.isLoadingForSignUp.isTrue
                      ? CustomButtonWithSplash(
                        px: 0,
                        py: 8,
                        borderRadius: 6.8,
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            await controller.register();
                          }
                        },
                        title: 'Sign Up',
                      )
                      : const CircularProgressIndicator();
                }),
              ),
              const SizedBox(height: 16),
              Hero(
                tag: 'auth_footer',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Already have an account?".text.bold.make(),
                    TextButton(
                      onPressed: () {
                        controller.changeSlidingValue(0);
                      },
                      child: 'Sign In'.text.bold.make(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
