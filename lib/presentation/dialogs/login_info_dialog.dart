import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

showSignupInfoDialog(BuildContext context) async {
  const primaryColor = Color(0xff4D4DCD);

  AlertDialog alert = AlertDialog(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.white,
    contentPadding: EdgeInsets.all(3.w),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
    content: SizedBox(
      width: 80.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 6.w),
              2.w.widthBox,
              "Account & Master Password".text.bold
                  .color(primaryColor)
                  .size(16.sp)
                  .make(),
            ],
          ).pOnly(bottom: 1.h),
          Divider(thickness: 0.1.h, color: primaryColor),
          "🔐 Your Account is linked to your email or username and allows access to the app."
              .text
              .color(Colors.black87)
              .size(11.sp)
              .make()
              .py(1.h),
          "🧠 The Master Password is the only key to access your secured data. It is never stored, so if you forget it, we cannot recover it!"
              .text
              .medium
              .color(Colors.black87)
              .size(11.sp)
              .make()
              .py(1.h),
          "⚠️ Please choose a strong Master Password and remember it securely."
              .text
              .bold
              .color(Colors.redAccent)
              .size(11.sp)
              .make()
              .pOnly(top: 1.h),
          Divider(thickness: 0.1.h, color: primaryColor).py(2.h),
          Material(
            borderRadius: BorderRadius.circular(2.w),
            child: InkWell(
              splashColor: Colors.redAccent,
              borderRadius: BorderRadius.circular(2.w),
              child: Ink(
                height: 5.h,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: "Got It".text.white.bold.size(12.sp).make().px(2.w),
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ).centered().pOnly(bottom: 1.h),
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
        child: Transform.scale(scale: curve, child: Container(child: alert)),
      );
    },
  );
}
