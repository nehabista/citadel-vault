import 'package:citadel_password_manager/logic/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../utils/validator.dart';
import '../../widgets/custom_button_with_splash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: context.isMobile ? context.screenWidth * 0.9 : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'auth_title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Hello There!',
                    style: GoogleFonts.pacifico(
                      textStyle: const TextStyle(fontSize: 32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Hero(
                tag: 'auth_subtitle',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Unlock your digital fortress to continue',
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
                autofillHints: const [AutofillHints.email],
                controller: controller.emailControllerForLogin,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  controller.emailControllerForLogin.text = value!;
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
                  obscureText: controller.passwordVisibility['login']!,
                  autofocus: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  autofillHints: const [AutofillHints.password],
                  controller: controller.passwordControllerForLogin,
                  onSaved: (value) {
                    controller.passwordControllerForLogin.text = value!;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    fillColor: Color.fromARGB(15, 77, 77, 205),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      controller.passwordVisibility['login']!
                          ? Bootstrap.lock
                          : Bootstrap.unlock,
                    ),
                    suffixIcon: Icon(
                      controller.passwordVisibility['login']!
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ).onTap(() {
                      controller.togglePasswordVisibility('login');
                    }),
                    hintText: 'Enter Account Password',
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Password can't be Empty");
                    }
                    return null;
                  },
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
                      controller.passwordVisibility['masterLogin']!
                          ? Bootstrap.lock
                          : Bootstrap.unlock,
                    ),
                    suffixIcon: Icon(
                      controller.passwordVisibility['masterLogin']!
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ).onTap(() {
                      controller.togglePasswordVisibility('masterLogin');
                    }),
                    hintText: 'Enter Master Password',
                    labelText: 'Master Password',
                  ),
                  validator: Validator().password,
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: 'Forgot Password?'.text.semiBold.make(),
                ),
              ),
              Hero(
                tag: 'auth_button',
                child: Obx(() {
                  return !controller.isLoadingForLogin.isTrue
                      ? CustomButtonWithSplash(
                        px: 0,
                        borderRadius: 6.8,
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            await controller.login();
                          }
                        },
                        title: 'Login',
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
                    "Don't have an account?".text.bold.make(),
                    TextButton(
                      onPressed: () async {
                        controller.changeSlidingValue(1);
                      },
                      child: 'Sign Up'.text.bold.make(),
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
