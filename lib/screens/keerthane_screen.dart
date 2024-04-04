import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:hymns_latest/keerthanes_def.dart'; // Assuming this still contains Hymn class and loadHymns function
import 'package:hymns_latest/keerthane_detail_screen.dart';

class KeerthaneScreen extends StatefulWidget {
  const KeerthaneScreen({super.key});

  @override
  _KeerthaneScreenState createState() => _KeerthaneScreenState();
}

class _KeerthaneScreenState extends State<KeerthaneScreen> {
  List<Keerthane> keerthane = []; 

  @override
  void initState() {
    super.initState();
    loadKeerthane().then((data) => setState(() => keerthane = data)); // Load keerthane
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const custom.SearchBar(
              hintText: 'Search Keerthane',
              hintStyle: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            Expanded( 
              child: ListView.builder(
                itemCount: keerthane.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Keerthane ${keerthane[index].number}: ${keerthane[index].title}'),
                    onTap: () => navigateToKeerthaneDetail(context, keerthane[index]), 
                  );
                },
              ),
            ),
          ],
        ),
      ), 
    );
  }

  // Add the navigation function
  void navigateToKeerthaneDetail(BuildContext context, Keerthane keerthane) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeerthaneDetailScreen(keerthane: keerthane)),
    );
  }
}
