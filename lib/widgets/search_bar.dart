import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key, 
    required this.hintText, 
    this.hintStyle,
  });

  final String hintText;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0), 
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: hintStyle ?? const TextStyle(),
          icon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
