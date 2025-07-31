import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color.fromARGB(255, 28, 145, 242) : Colors.blueGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(255, 26, 147, 246).withAlpha(20)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ).py(8).px(9),
    );
  }
}
