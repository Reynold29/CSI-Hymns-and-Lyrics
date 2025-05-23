import 'package:flutter/material.dart';

class GestureControl extends StatelessWidget {
  final Widget child;
  final Function(int)? onPageChanged;
  final int currentIndex;
  final int pageCount;

  const GestureControl({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.pageCount,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < 0 && currentIndex < pageCount - 1) {
          // Swipe left
          onPageChanged?.call(currentIndex + 1);
        } else if (details.primaryVelocity! > 0 && currentIndex > 0) {
          // Swipe right
          onPageChanged?.call(currentIndex - 1);
        }
      },
      child: child,
    );
  }
}
