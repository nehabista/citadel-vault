// File: lib/presentation/dialogs/login_info_dialog.dart
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

Future<void> showSignupInfoDialog(BuildContext context) async {
  const primaryColor = Color(0xff4D4DCD);
  final screenWidth = MediaQuery.of(context).size.width;

  final alert = AlertDialog(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.white,
    contentPadding: EdgeInsets.all(screenWidth * 0.03),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02)),
    content: SizedBox(
      width: screenWidth * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: primaryColor, size: screenWidth * 0.06),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Account & Master Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: screenWidth * 0.042,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: primaryColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Your Account is linked to your email or username and allows access to the app.",
              style: TextStyle(
                  color: Colors.black87, fontSize: screenWidth * 0.032),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "The Master Password is the only key to access your secured data. It is never stored, so if you forget it, we cannot recover it!",
              style: TextStyle(
                color: Colors.black87,
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Please choose a strong Master Password and remember it securely.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                fontSize: screenWidth * 0.032,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Divider(thickness: 1, color: primaryColor),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: InkWell(
                  splashColor: Colors.redAccent,
                  borderRadius:
                      BorderRadius.circular(screenWidth * 0.02),
                  onTap: () => Navigator.pop(context),
                  child: Ink(
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius:
                          BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: Text(
                          "Got It",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  await showGeneralDialog(
    pageBuilder: (context, anim1, anim2) => Container(),
    context: context,
    transitionBuilder: (ctx, a1, a2, child) {
      final curve = Curves.easeInOut.transform(a1.value);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Transform.scale(scale: curve, child: alert),
      );
    },
  );
}
