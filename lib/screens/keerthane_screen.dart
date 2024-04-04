import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;

class KeerthaneScreen extends StatelessWidget {
  const KeerthaneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            custom.SearchBar(
              hintText: 'Search Keerthane',
              hintStyle: TextStyle(color: Colors.black),
              ),
            SizedBox(height: 20),
            Expanded( 
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(Icons.music_note, size: 60, color: Colors.grey),
                    SizedBox(height: 15),
                    Text(
                      'Keerthane List Coming Soon!',
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
