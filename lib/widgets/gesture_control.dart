import 'package:flutter/material.dart';

class GestureControl extends StatelessWidget {
  final Widget child;
  final Function(int)? onPageChanged;  

  const GestureControl({super.key, required this.child, this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          onPageChanged?.call(1); 
        } else {
          onPageChanged?.call(0);
        }
      },
      child: child, 
    );
  }
}
