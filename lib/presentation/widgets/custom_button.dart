import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    required this.context,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.border,
  });

  final BuildContext context;
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.blue.withValues(
          red: 0,
          green: 0,
          blue: 0,
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  red: 0,
                  green: 0,
                  blue: 0,
                  alpha: 0.1,
                ),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              8.widthBox,
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
