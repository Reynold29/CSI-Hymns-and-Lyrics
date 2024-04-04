import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:hymns_latest/hymns_def.dart';
import 'package:hymns_latest/hymns_data.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';

class HymnsScreen extends StatelessWidget {
  const HymnsScreen({super.key});

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
                itemCount: hymnList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Hymn ${hymnList[index].number}: ${hymnList[index].title}'), 
                    onTap: () => navigateToHymnDetail(context, hymnList[index]),  
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
