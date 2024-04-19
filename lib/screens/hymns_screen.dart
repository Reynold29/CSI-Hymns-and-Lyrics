import 'package:flutter/material.dart';
import 'package:hymns_latest/hymns_def.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:showcaseview/showcaseview.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({Key? key}) : super(key: key);

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  GlobalKey _searchKey = GlobalKey();
  GlobalKey _filterKey = GlobalKey();
  List<Hymn> hymns = [];
  List<Hymn> filteredHymns = [];
  String? _selectedOrder = 'number';
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    loadHymns().then((data) => setState(() {
          hymns = data;
          hymns.sort((a, b) => a.number.compareTo(b.number));
          filteredHymns = hymns;
        }));
      /* Future.delayed(const Duration(seconds: 7), () {
      ShowCaseWidget.of(context).startShowCase([
        _searchKey,
        _filterKey,
      ]);
      _checkFirstRun();
    });*/
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

  /*Future<void> _checkFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = (prefs.getBool('isFirstRun') ?? true);

  if (isFirstRun) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([ _searchKey, _filterKey ]); 
    });
    prefs.setBool('isFirstRun', false);
  }
}*/

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
                    description: 'Find hymns by Title or Number',
                    targetShapeBorder: const CircleBorder(),
                    overlayColor: const Color.fromARGB(139, 0, 0, 0).withOpacity(0.6),  
                    titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
                    child: custom.SearchBar(
                      hintText: 'Search Hymns',
                      hintStyle: const TextStyle(color: Colors.black),
                      onChanged: (searchQuery) {
                        setState(() {
                          _searchQuery = searchQuery;
                          if (searchQuery.isEmpty) {
                            filteredHymns = hymns;
                          } else {
                            filteredHymns = hymns.where((hymn) =>
                                hymn.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                hymn.number.toString().contains(searchQuery.toLowerCase())).toList();
                          }
                        }
                      );
                    },
                  )
                )
              ),
              Showcase(
                key: _filterKey,
                title: 'Filter Hymns',
                description: 'Sort hymns by number or title.',
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
                  const PopupMenuItem(child: Text("Order by Hymn No."), value: "number"),
                  const PopupMenuItem(child: Text("Order by Alphabetical"), value: "title")
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
              child: ListView.builder(
                itemCount: _searchQuery != null ? filteredHymns.length : hymns.length,
                itemBuilder: (context, index) {
                  final hymn = _searchQuery != null ? filteredHymns[index] : hymns[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
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
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                      onTap: () => navigateToHymnDetail(context, hymn),
                    ),
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
