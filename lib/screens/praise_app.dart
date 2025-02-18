import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PraiseAppScreen extends StatelessWidget {
  const PraiseAppScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Praise and Worship App")),
      body: const Center( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.googlePlay),
            SizedBox(height: 16),
            Text(
              "App Coming Soon!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), 
            ),
          ],
        ),
      ),
    );
  }
}