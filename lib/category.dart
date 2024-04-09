import 'package:flutter/material.dart';
import 'package:hymns_latest/screens/category_screen.dart';

class SidebarOptions {
  static List<Widget> getOptions(BuildContext context) {
    return [
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "Jesus' Birth",)),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Jesus' Birth",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "Jesus' Passion and Death")),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Jesus' Passion and Death",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "Jesus' Resurrection")),
          );
        },
        leading: const SizedBox(
          height: 34,
          width: 34,
          child: Icon(Icons.collections_bookmark),
        ),
        title: const Text(
          "Jesus' Resurrection",
          style: TextStyle(color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "Jesus' Ascension and His Kingdom")),
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
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "Jesus' Coming Again")),
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
            MaterialPageRoute(builder: (context) => const CategoryScreen(category: "All Categories")),
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
