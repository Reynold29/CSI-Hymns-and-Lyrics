import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom; 
import 'package:hymns_latest/keerthanes_def.dart'; 
import 'package:hymns_latest/keerthane_detail_screen.dart';

class KeerthaneScreen extends StatefulWidget {
  const KeerthaneScreen({super.key});

  @override
  _KeerthaneScreenState createState() => _KeerthaneScreenState();
}

class _KeerthaneScreenState extends State<KeerthaneScreen> {
  List<Keerthane> keerthane = []; 
  List<Keerthane> filteredKeerthane = [];
  String? _selectedOrder = 'number';
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    loadKeerthane().then((data) => setState(() {
      keerthane = data;
      keerthane.sort((a, b) => a.number.compareTo(b.number));
      filteredKeerthane = keerthane;
    }));
  }

  void _sortKeerthane() {
    setState(() {
      _searchQuery = null;
      if (_selectedOrder == 'number') {
        keerthane.sort((a, b) => a.number.compareTo(b.number));
      } else if (_selectedOrder == 'title') {
        keerthane.sort((a, b) => a.title.compareTo(b.title));
      }
      filteredKeerthane = keerthane;
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
              hintText: 'Search Keerthane',
              hintStyle: TextStyle(color: Colors.black),
              onChanged: (searchQuery) {
                setState(() {
                  _searchQuery = searchQuery;
                  if (searchQuery.isEmpty) {
                    filteredKeerthane = keerthane; 
                  } else {
                    filteredKeerthane = keerthane.where((Keerthane) =>
                        Keerthane.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        Keerthane.number.toString().contains(searchQuery.toLowerCase())
                    ).toList();
                  }
                });
              },
            )),
            PopupMenuButton<String>( 
              onSelected: (selectedOrder) {
                setState(() {
                  _selectedOrder = selectedOrder;
                  _sortKeerthane(); 
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(child: Text("Order by Keerthane No."), value: "number"),
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
                itemCount: _searchQuery != null ? filteredKeerthane.length : keerthane.length,
                itemBuilder: (context, index) {
                  final Keerthane = _searchQuery != null ? filteredKeerthane[index] : keerthane[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 40,
                      child: Image.asset('lib/assets/icons/keerthane.png') 
                      ),
                    title: Text('Keerthane ${Keerthane.number}: ${Keerthane.title}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    onTap: () => navigateToKeerthaneDetail(context, Keerthane), 
                  );
                },
              ),
            ),
          ],
        ),
      ), 
    );
  }

  void navigateToKeerthaneDetail(BuildContext context, Keerthane keerthane) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeerthaneDetailScreen(keerthane: keerthane)),
    );
  }
}
