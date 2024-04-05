import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom; 
import 'package:hymns_latest/hymns_def.dart'; 
import 'package:hymns_latest/hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  List<Hymn> hymns = []; 
  List<Hymn> filteredHymns = [];
  String? _selectedOrder = 'number';
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    loadHymns().then((data) => setState(() => hymns = data));
  }

  void _sortHymns() {
    setState(() {
      _searchQuery = null;
      if (_selectedOrder == 'number') {
        hymns.sort((a, b) => a.number.compareTo(b.number));
      } else if (_selectedOrder == 'title') {
        hymns.sort((a, b) => a.title.compareTo(b.title));
      }
      filteredHymns = hymns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: custom.SearchBar(
              hintText: 'Search Hymns',
              hintStyle: TextStyle(color: Colors.black),
              onChanged: (searchQuery) {
                setState(() {
                  _searchQuery = searchQuery;
                  if (searchQuery.isEmpty) {
                    filteredHymns = hymns; 
                  } else {
                    filteredHymns = hymns.where((hymn) =>
                        hymn.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        hymn.number.toString().contains(searchQuery.toLowerCase())
                    ).toList();
                  }
                });
              },
            )),
            PopupMenuButton<String>( 
              onSelected: (selectedOrder) {
                setState(() {
                  _selectedOrder = selectedOrder;
                  _sortHymns(); 
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(child: Text("Order by Hymn No."), value: "number"),
                  PopupMenuItem(child: Text("Order by Alphabetical"), value: "title")
                ];
              },
              icon: Icon(Icons.filter_list), 
            ),
          ],
        ),
        toolbarHeight: 100, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded( 
              child: ListView.builder(
                itemCount: _searchQuery != null ? filteredHymns.length : hymns.length,
                itemBuilder: (context, index) {
                  final hymn = _searchQuery != null ? filteredHymns[index] : hymns[index];
                  return ListTile(
                    title: Text('Hymn ${hymn.number}: ${hymn.title}'), 
                    onTap: () => navigateToHymnDetail(context, hymn), 
                  );
                },
              ),
            ),
          ],
        ),
      ), 
    );
  }

  void navigateToHymnDetail(BuildContext context, Hymn hymn) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
    );
  }
}
