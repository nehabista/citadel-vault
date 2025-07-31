import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomButtonWithSplash extends StatelessWidget {
  final void Function()? onTap;
  final double? borderRadius;
  final double? textPx;
  final double? textPy;
  final double? px;
  final double? py;
  final double? textPOnlyTop;
  final double? textPOnlyBottom;
  final double? textPOnlyLeft;
  final double? textPOnlyRight;
  final double? textPxRow;
  final String title;
  final double? textScale;
  final Color? splashColor;
  final double? height;
  final Color? colorDarkMode;
  final Color? colorLightMode;
  final Color? textColor;
  const CustomButtonWithSplash({
    super.key,
    required this.onTap,
    this.textPx,
    this.textPy,
    this.textPOnlyTop,
    this.textPOnlyBottom,
    this.textPOnlyLeft,
    this.textPOnlyRight,
    this.textPxRow,
    this.px,
    this.py,
    this.borderRadius,
    required this.title,
    this.textScale,
    this.splashColor,
    this.height,
    this.colorDarkMode,
    this.colorLightMode,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: InkWell(
        splashColor: splashColor ?? Colors.redAccent,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        onTap: onTap,
        child: Ink(
          height: height ?? 35,
          decoration: BoxDecoration(
            color: colorDarkMode ?? const Color(0xff4D4DCD),
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: title.text
                    .scale(textScale ?? 1.25)
                    .color(textColor ?? Colors.white)
                    .extraBold
                    .make()
                    .px(textPx ?? 4)
                    .py(textPy ?? 0)
                    .pOnly(
                      right: textPOnlyRight ?? 0,
                      left: textPOnlyLeft ?? 0,
                      bottom: textPOnlyBottom ?? 0,
                      top: textPOnlyTop ?? 0,
                    ),
              ),
            ],
          ).px(textPxRow ?? 0),
        ),
      ),
    ).centered().px(px ?? 12).py(py ?? 8);
  }
}
