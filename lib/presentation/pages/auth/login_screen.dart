// File: lib/presentation/pages/auth/login_screen.dart
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: width,
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                autofocus: false,
                autofillHints: const [AutofillHints.email],
                controller: notifier.emailLoginController,
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
                obscureText: authState.passwordVisibility['login'] ?? true,
                autofocus: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autofillHints: const [AutofillHints.password],
                controller: notifier.passwordLoginController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(15, 77, 77, 205),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    (authState.passwordVisibility['login'] ?? true)
                        ? Bootstrap.lock
                        : Bootstrap.unlock,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => notifier.togglePasswordVisibility('login'),
                    child: Icon(
                      (authState.passwordVisibility['login'] ?? true)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: 'Enter Account Password',
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password can't be Empty";
                  }
                  return null;
                },
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
                    (authState.passwordVisibility['masterLogin'] ?? true)
                        ? Bootstrap.lock
                        : Bootstrap.unlock,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        notifier.togglePasswordVisibility('masterLogin'),
                    child: Icon(
                      (authState.passwordVisibility['masterLogin'] ?? true)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: 'Enter Master Password',
                  labelText: 'Master Password',
                ),
                validator: Validator().password,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Hero(
                tag: 'auth_button',
                child: !authState.isLoadingLogin
                    ? CustomButtonWithSplash(
                        px: 0,
                        borderRadius: 6.8,
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            final result = await notifier.login();
                            if (!mounted) return;
                            if (result.success) {
                              context.go(AppRoutes.home);
                            } else if (result.needsVerification &&
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
                        title: 'Login',
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              Hero(
                tag: 'auth_footer',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => notifier.changeSlidingValue(1),
                      child: const Text('Sign Up',
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
