import 'package:flutter/material.dart';
import 'package:hymns_latest/categories/category1.dart';
import 'package:hymns_latest/categories/category2.dart';
import 'package:hymns_latest/categories/category3.dart';
import 'package:hymns_latest/categories/category4.dart';
import 'package:hymns_latest/categories/category5.dart';
import 'package:hymns_latest/categories/category6.dart';

class SidebarOptions {
  static List<Widget> getOptions(BuildContext context) {
    return [
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category1Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Christmas",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category2Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Lent and Good Friday",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category3Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Easter",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category4Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Jesus' Ascension and His Kingdom",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category5Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Jesus' Coming Again",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Category6Screen()),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.menu_open),
        ),
        title: const Text(
          "More Categories...",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
  }
}
