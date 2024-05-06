import 'package:flutter/material.dart';
import 'package:hymns_latest/category.dart';
import 'package:hymns_latest/screens/about_app.dart';
import 'package:hymns_latest/screens/praise_app.dart';
import 'package:hymns_latest/screens/settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hymns_latest/screens/about_developer_screen.dart';

class Sidebar extends StatefulWidget {
  final AnimationController animationController;

  const Sidebar({super.key, required this.animationController});

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
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: FaIcon(
                      FontAwesomeIcons.church,
                      size: 30,
                    ),
                  ),
                  title: const Text(
                    "CSI Hymns and Lyrics",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'plusJakartaSans', color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Praise The Lord!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w100,
                      fontFamily: 'plusJakartaSans',
                    ),
                  ),
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutApp()),
                  );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 34),
                  child: Divider(
                    color: Color.fromARGB(133, 220, 220, 220),
                    height: 1,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PraiseAppScreen()),
                    );
                  },
                  leading: const SizedBox(
                    height: 34,
                    width: 34,
                    child: FaIcon(FontAwesomeIcons.googlePlay),
                  ),
                  title: const Text("Praise and Worship App", style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
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
                      semanticLabel: _showOptions ? 'Collapse Categories' : 'Expand Categories',
                      ),
                    ],
                  ),
                ),
                if (_showOptions) ...SidebarOptions.getOptions(context).map((option) =>
                  Material(
                    color: const Color.fromARGB(0, 188, 188, 188),
                    child: InkWell(
                      onTap: () {
                        // Handle tap action //
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
                  title: Semantics(
                    label: 'Open app settings', 
                    child: const Text("Settings", style: TextStyle(color: Colors.white)), 
                  ),
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
                  title: Semantics(
                    label: "About Develoepr",
                    child: const Text("About Developer", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
