// File: lib/presentation/pages/onboarding/onboarding_widget.dart
import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ],
      ),
    );
  }
}
