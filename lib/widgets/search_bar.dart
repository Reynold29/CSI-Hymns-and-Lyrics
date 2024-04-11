import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {

  final ValueChanged<String>? onChanged;

  const SearchBar({super.key, 
    required this.hintText, 
    this.hintStyle,
    this.onChanged
  });

  final String hintText;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), 
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0), 
            child: Icon(Icons.search, color: Colors.black,
            ),
          ),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: hintStyle ?? const TextStyle(),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
