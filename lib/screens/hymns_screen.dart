import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:hymns_latest/hymns_def.dart'; // Assuming this still contains Hymn class and loadHymns function
import 'package:hymns_latest/hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  List<Hymn> hymns = []; 

  @override
  void initState() {
    super.initState();
    loadHymns().then((data) => setState(() => hymns = data)); // Load hymns
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const custom.SearchBar(
              hintText: 'Search Hymns',
              hintStyle: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            Expanded( 
              child: ListView.builder(
                itemCount: hymns.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Hymn ${hymns[index].number}: ${hymns[index].title}'),
                    onTap: () => navigateToHymnDetail(context, hymns[index]), 
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
  void navigateToHymnDetail(BuildContext context, Hymn hymn) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
    );
  }
}
