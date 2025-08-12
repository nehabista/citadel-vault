// File: lib/presentation/widgets/custom_button_with_splash.dart
import 'package:flutter/material.dart';

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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: px ?? 12,
          vertical: py ?? 8,
        ),
        child: Material(
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: textPxRow ?? 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: textPOnlyLeft ?? 0,
                          right: textPOnlyRight ?? 0,
                          top: textPOnlyTop ?? 0,
                          bottom: textPOnlyBottom ?? 0,
                        ).add(EdgeInsets.symmetric(
                          horizontal: textPx ?? 4,
                          vertical: textPy ?? 0,
                        )),
                        child: Text(
                          title,
                          textScaler: TextScaler.linear(textScale ?? 1.25),
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
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
