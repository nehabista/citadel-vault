// File: lib/presentation/pages/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../utils/validator.dart';
import '../../widgets/custom_button_with_splash.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../routing/app_router.dart';
import '../../widgets/citadel_snackbar.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    return Form(
      key: _formKey,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: width,
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                autofocus: false,
                autofillHints: const [AutofillHints.name],
                controller: notifier.nameSignUpController,
                keyboardType: TextInputType.name,
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
                controller: notifier.emailSignUpController,
                keyboardType: TextInputType.emailAddress,
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
              TextFormField(
                obscureText: authState.passwordVisibility['signUp'] ?? true,
                autofocus: false,
                autofillHints: const [AutofillHints.password],
                controller: notifier.passwordSignUpController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(15, 77, 77, 205),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    (authState.passwordVisibility['signUp'] ?? true)
                        ? Bootstrap.lock
                        : Bootstrap.unlock,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => notifier.togglePasswordVisibility('signUp'),
                    child: Icon(
                      (authState.passwordVisibility['signUp'] ?? true)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: 'Enter Account Password',
                  labelText: 'Password',
                ),
                validator: Validator().password,
              ),
              const SizedBox(height: 15),
              TextFormField(
                obscureText: authState.passwordVisibility['master'] ?? true,
                autofocus: false,
                autofillHints: const [AutofillHints.password],
                controller: notifier.masterPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(15, 77, 77, 205),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    (authState.passwordVisibility['master'] ?? true)
                        ? Bootstrap.lock
                        : Bootstrap.unlock,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => notifier.togglePasswordVisibility('master'),
                    child: Icon(
                      (authState.passwordVisibility['master'] ?? true)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: 'Enter Master Password',
                  labelText: 'Master Password',
                ),
                validator: Validator().password,
              ),
              const SizedBox(height: 16),
              Hero(
                tag: 'auth_button',
                child: !authState.isLoadingSignUp
                    ? CustomButtonWithSplash(
                        px: 0,
                        py: 8,
                        borderRadius: 6.8,
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            final result = await notifier.register();
                            if (!mounted) return;
                            if (result.needsVerification &&
                                result.email != null) {
                              context.go(AppRoutes.verification,
                                  extra: result.email);
                            } else if (result.error != null) {
                              showCitadelSnackBar(
                                  context, result.error!,
                                  type: SnackBarType.error);
                            }
                          }
                        },
                        title: 'Sign Up',
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              Hero(
                tag: 'auth_footer',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => notifier.changeSlidingValue(0),
                      child: const Text('Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
