import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;

class HymnsScreen extends StatelessWidget {
  const HymnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            custom.SearchBar(
              hintText: 'Search Hymns',
              hintStyle: TextStyle(color: Colors.black),
              ),
            const SizedBox(height: 20),
            const Expanded( 
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(Icons.music_note, size: 60, color: Colors.grey),
                    SizedBox(height: 15),
                    Text(
                      'Hymns List Coming Soon!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), 
    );
  }
}
