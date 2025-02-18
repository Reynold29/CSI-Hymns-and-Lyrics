import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category6Screen extends StatelessWidget {
  const Category6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("More Categories")),
      body: const Center( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.layerGroup),
            SizedBox(height: 16),
            Text(
              "More Categories Coming Soon!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), 
            ),
          ],
        ),
      ),
    );
  }
}
