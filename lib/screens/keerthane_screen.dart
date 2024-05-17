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
  final FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadKeerthane().then((data) => setState(() {
      keerthane = data;
      keerthane.sort((a, b) => a.number.compareTo(b.number));
      filteredKeerthane = keerthane;
      _scrollController.addListener(_scrollListener);
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
      filteredKeerthane = List.from(keerthane);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // ignore: unused_field
  bool _showScrollToTopButton = false;

  void _scrollListener() {
    setState(() {
      _showScrollToTopButton = _scrollController.offset >= 400;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: custom.SearchBar(
                hintText: 'Search Keerthane',
                hintStyle: const TextStyle(color: Colors.black),
                onChanged: (searchQuery) {
                  setState(() {
                    _searchQuery = searchQuery;
                    if (searchQuery.isEmpty) {
                      filteredKeerthane = List.from(keerthane);
                    } else {
                      filteredKeerthane = keerthane.where((keerthane) =>
                        keerthane.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        keerthane.number.toString().contains(searchQuery.toLowerCase())
                      ).toList();
                    }
                  });
                }, 
                focusNode: _searchFocusNode,
                onQueryCleared: () {
                  setState(() {
                    _searchQuery = null; 
                    filteredKeerthane = List.from(keerthane); 
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _searchFocusNode.unfocus();
                    });
                  });
                },
              ),
            ),
            PopupMenuButton<String>( 
              onSelected: (selectedOrder) {
                setState(() {
                  _selectedOrder = selectedOrder;
                  _sortKeerthane(); 
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(value: "number", child: Text("Order by Keerthane No.")),
                  const PopupMenuItem(value: "title", child: Text("Order by Alphabetical"))
                ];
              },
              icon: const Icon(Icons.filter_list), 
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
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _searchQuery != null ? filteredKeerthane.length : keerthane.length,
                    itemBuilder: (context, index) {
                      final keerthaneItem = _searchQuery != null ? filteredKeerthane[index] : keerthane[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 50,
                              height: 40,
                              child: Semantics(
                                label: 'Keerthane icon', 
                                child: Image.asset(
                                  'lib/assets/icons/keerthane.png', 
                                ),
                              ), 
                            ),
                          ),
                          title: Text('Keerthane ${keerthaneItem.number}: ${keerthaneItem.title}',
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                          onTap: () => navigateToKeerthaneDetail(context, keerthaneItem), 
                        ),
                      );
                    },
                  ),
                  if (_showScrollToTopButton)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _scrollToTop,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        elevation: 6.0,
                        child: const Icon(Icons.arrow_upward),
                      ),
                    ),
                ],
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