import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hymns_latest/category.dart';
import 'package:hymns_latest/screens/about_developer_screen.dart';
import 'package:hymns_latest/screens/settings_screen.dart';
import 'package:hymns_latest/screens/changelog_screen.dart';

class Sidebar extends StatefulWidget {
  final AnimationController animationController;

  const Sidebar({Key? key, required this.animationController}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _showOptions = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: 288,
          height: double.infinity,
          color: Colors.black,
          child: SafeArea(
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 21, vertical: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: FaIcon(
                      FontAwesomeIcons.church,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    "CSI Hymns and Lyrics",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'plusJakartaSans', color: Colors.white),
                  ),
                  subtitle: Text(
                    "Praise The Lord!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w100,
                      fontFamily: 'plusJakartaSans',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 34),
                  child: Divider(
                    color: Color.fromARGB(133, 220, 220, 220),
                    height: 1,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.house),
                  ),
                  title: const Text("HOME", style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  onTap: () {
                    setState(() {
                      _showOptions = !_showOptions;
                    });
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.bookBible),
                  ),
                  title: Row(
                    children: [
                      const Text("Categories", style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Icon(
                        _showOptions ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (_showOptions) ...SidebarOptions.getOptions(context).map((option) =>
                  Material(
                    color: const Color.fromARGB(0, 188, 188, 188),
                    child: InkWell(
                      onTap: () {
                        // Handle tap action
                      },
                      child: option,
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(
                  color: Color.fromARGB(133, 220, 220, 220),
                  height: 1,
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.gear),
                  ),
                  title: const Text("Settings", style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangelogScreen()),
                    );
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.scroll),
                  ),
                  title: const Text("What's New?", style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutDeveloper()),
                    );
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.circleUser),
                  ),
                  title: const Text("About Developer", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
