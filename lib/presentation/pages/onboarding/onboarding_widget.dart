// widgets/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

class OnboardingPage extends StatelessWidget {
  final double topSpacing;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.topSpacing,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          title.text.size(15.sp).extraBold.maxLines(1).make(),
          1.h.heightBox,
          description.text.size(10.5.sp).make(),
        ],
      ),
    );
  }
}
