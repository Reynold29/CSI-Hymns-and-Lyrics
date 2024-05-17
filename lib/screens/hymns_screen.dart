import 'package:flutter/material.dart';
import 'package:hymns_latest/hymns_def.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:showcaseview/showcaseview.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  List<Hymn> hymns = [];
  List<Hymn> filteredHymns = [];
  Map<String, List<Hymn>> groupedHymns = {};
  String? _selectedOrder = 'number';
  String? _searchQuery;
  final FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadHymns().then((data) => setState(() {
          hymns = data;
          _sortHymns();
          _scrollController.addListener(_scrollListener);
        }));
  }

  void _sortHymns() {
    setState(() {
      if (_selectedOrder == 'number') {
        hymns.sort((a, b) => a.number.compareTo(b.number));
        filteredHymns = hymns;
      } else if (_selectedOrder == 'title') {
        hymns.sort((a, b) => a.title.compareTo(b.title));
        filteredHymns = hymns;
      } else if (_selectedOrder == 'time_signature') {
        hymns.sort((a, b) => a.signature.compareTo(b.signature));
        _groupHymnsBySignature();
      }
      _filterHymns();
    });
  }

  void _filterHymns() {
    setState(() {
      if (_searchQuery == null || _searchQuery!.isEmpty) {
        filteredHymns = List.from(hymns);
        if (_selectedOrder == 'time_signature') {
          _groupHymnsBySignature();
        }
      } else {
        final query = _searchQuery!.toLowerCase().trim(); 
        if (_selectedOrder == 'time_signature') {
          groupedHymns = Map.fromEntries(
            groupedHymns.entries.where((entry) {
              // ignore: unused_local_variable
              final signature = entry.key.toLowerCase();
              final hymnsInSignature = entry.value.where((hymn) => 
                hymn.title.toLowerCase().contains(query) ||
                hymn.number.toString().contains(query) ||
                hymn.signature.toLowerCase().contains(query)
              ).toList();
              return hymnsInSignature.isNotEmpty;
            })
          );
          filteredHymns = groupedHymns.values.expand((x) => x).toList();
        } else {
          filteredHymns = hymns.where((hymn) {
            final hymnSignature = hymn.signature.toLowerCase();
            return hymn.title.toLowerCase().contains(query) ||
                   hymn.number.toString().contains(query) ||
                   hymnSignature == query; 
          }).toList();
        }
      }
    });
  }

  void _groupHymnsBySignature() {
    groupedHymns.clear();
    for (var hymn in hymns) {
      if (!groupedHymns.containsKey(hymn.signature)) {
        groupedHymns[hymn.signature] = [];
      }
      groupedHymns[hymn.signature]!.add(hymn);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

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
              child: Showcase(
                key: _searchKey,
                title: 'Search Hymns',
                description: 'Find hymns by Title, Number, or Time Signature',
                targetShapeBorder: const CircleBorder(),
                overlayColor: const Color.fromARGB(139, 0, 0, 0).withOpacity(0.6),
                titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
                child: custom.SearchBar(
                  hintText: 'Search Hymns',
                  hintStyle: const TextStyle(color: Colors.black),
                  onChanged: (searchQuery) {
                    setState(() {
                      _searchQuery = searchQuery;
                      _filterHymns();
                    });
                  }, 
                  focusNode: _searchFocusNode,
                  onQueryCleared: () {
                    setState(() {
                      _searchQuery = null; 
                      _filterHymns();
                      _groupHymnsBySignature();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _searchFocusNode.unfocus();
                      });
                    });
                  },
                ),
              ),
            ),
            Showcase(
              key: _filterKey,
              title: 'Filter Hymns',
              description: 'Sort hymns by number, title, or time signature.',
              targetShapeBorder: const CircleBorder(),
              overlayColor: const Color.fromARGB(139, 0, 0, 0).withOpacity(0.6),
              titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
              child: PopupMenuButton<String>(
                onSelected: (selectedOrder) {
                  setState(() {
                    _selectedOrder = selectedOrder;
                    _sortHymns();
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(value: "number", child: Text("Order by Hymn No.")),
                    const PopupMenuItem(value: "title", child: Text("Order by Alphabetical")),
                    const PopupMenuItem(value: "time_signature", child: Text("Order by Tune Meter"))
                  ];
                },
                icon: const Icon(Icons.filter_list),
              ),
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
                    itemCount: _selectedOrder == 'time_signature'
                        ? groupedHymns.keys.length
                        : filteredHymns.length,
                    itemBuilder: (context, index) {
                      if (_selectedOrder == 'time_signature') {
                        String signature = groupedHymns.keys.elementAt(index);
                        List<Hymn> hymnsInSignature = groupedHymns[signature]!;
                        if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                          hymnsInSignature = hymnsInSignature.where((hymn) =>
                              hymn.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                              hymn.number.toString().contains(_searchQuery!.toLowerCase()) ||
                              hymn.signature.toLowerCase().contains(_searchQuery!.toLowerCase())).toList();
                        }
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  signature,
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                                  ),
                                ),
                                const SizedBox(height: 8),
                  
                                for (var hymn in hymnsInSignature)
                                  _buildHymnListTile(hymn),
                              ],
                            ),
                          ),
                        );
                  
                      } else {
                        final hymn = filteredHymns[index];
                        return _buildHymnListTile(hymn); 
                      }
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

  Widget _buildHymnListTile(Hymn hymn) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 45,
            height: 40,
            child: Semantics(
              label: 'Hymn icon',
              child: Image.asset(
                'lib/assets/icons/hymn.png',
              ),
            ),
          ),
        ),
        title: Text(
          'Hymn ${hymn.number}: ${hymn.title}',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
        onTap: () => navigateToHymnDetail(context, hymn),
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