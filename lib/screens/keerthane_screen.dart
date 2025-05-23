import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:hymns_latest/keerthanes_def.dart';
import 'package:hymns_latest/keerthane_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    loadKeerthane().then((data) {
      if (mounted) {
        setState(() {
          keerthane = data;
          _sortKeerthane();
          _isLoading = false;
        });
      }
    });
    _scrollController.addListener(_scrollListener);
    checkAndUpdateLyricsOnOpen();
  }

  Future<void> checkAndUpdateLyricsOnOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateTimestamp = prefs.getInt('lastLyricsUpdateKeerthane') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updateInterval = const Duration(days: 3).inMilliseconds;

    if (now - lastUpdateTimestamp >= updateInterval) {
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/keerthane_data.json'));

        if (response.statusCode == 200) {
          final List<Keerthane> updatedKeerthane = await loadKeerthaneFromNetwork(response.body);
          if (mounted) {
            setState(() {
              keerthane = updatedKeerthane;
              _sortKeerthane();
            });
            await prefs.setInt('lastLyricsUpdateKeerthane', now);
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Keerthane lyrics updated successfully!'),
                ));
            }
          }
        } else {
          throw Exception('Failed to fetch Keerthane data from cloud');
        }
      } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to update Keerthane lyrics. Please try again later.'),
            ));
        }
      }
    }
  }

  Future<void> checkAndUpdateLyrics() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Refresh Keerthane Lyrics?'),
          content: const Text('Do you want to check for updated Keerthane lyrics?'),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('YES'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    if (mounted) setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Updating Keerthane Lyrics...'),
          content: SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Lottie.asset('lib/assets/icons/tick-animation.json', width: 80, height: 80),
            ),
          ),
        );
      },
    );

    fetchAndUpdateLyrics().then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Keerthane Lyrics Updated!'),
              content: SizedBox(
                  height: 100, width: 100,
                  child: Lottie.asset('lib/assets/icons/tick-animation.json', width: 80, height: 80)),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Update Failed'),
              content: const Text('Failed to update Keerthane lyrics. Please try again later.'),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  Future<void> fetchAndUpdateLyrics() async {
    try {
      final keerthaneResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/keerthane_data.json'));

      if (keerthaneResponse.statusCode == 200) {
        final updatedKeerthanas = await loadKeerthaneFromNetwork(keerthaneResponse.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('keerthaneData', jsonEncode(updatedKeerthanas));
        if (mounted) {
          setState(() {
            keerthane = updatedKeerthanas;
            _sortKeerthane();
          });
        }
      } else {
        throw Exception('Failed to fetch Keerthane data from GitHub');
      }
    } catch (e) {
      print('Error updating Keerthane lyrics: $e');
      rethrow;
    }
  }

  void _sortKeerthane() {
    if (!mounted) return;
    setState(() {
      if (_selectedOrder == 'number') {
        keerthane.sort((a, b) => a.number.compareTo(b.number));
      } else if (_selectedOrder == 'title') {
        keerthane.sort((a, b) => a.title.compareTo(b.title));
      }
      _filterKeerthane();
    });
  }

  void _filterKeerthane() {
    if (!mounted) return;
    setState(() {
       if (_searchQuery == null || _searchQuery!.isEmpty) {
        filteredKeerthane = List.from(keerthane);
      } else {
        final query = _searchQuery!.toLowerCase().trim();
        filteredKeerthane = keerthane.where((k) =>
          k.title.toLowerCase().contains(query) ||
          k.number.toString().contains(query)
        ).toList();
      }
    });
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position.shift(const Offset(0, 8)),
      items: [
        const PopupMenuItem<String>(value: "number", child: Text("Order by Number")),
        const PopupMenuItem<String>(value: "title", child: Text("Order Alphabetically")),
      ],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedOrder = value;
          _sortKeerthane();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (mounted) {
      setState(() {
        _showScrollToTopButton = _scrollController.offset >= 400;
      });
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 130, // Ensuring this is 130
        backgroundColor: colorScheme.surface,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    custom.SearchBar(
                      hintText: 'Search Keerthane (Number, Title)',
                      onChanged: (searchQuery) {
                        setState(() {
                          _searchQuery = searchQuery;
                          _filterKeerthane();
                        });
                      },
                      focusNode: _searchFocusNode,
                      onQueryCleared: () {
                        setState(() {
                          _searchQuery = null;
                          _filterKeerthane();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _searchFocusNode.unfocus();
                          });
                        });
                      },
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      searchIconColor: colorScheme.onSurfaceVariant,
                      clearIconColor: colorScheme.onSurfaceVariant,
                      textStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Filter'),
                          onPressed: () => _showFilterMenu(context),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Lyrics'),
                          onPressed: checkAndUpdateLyrics,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (_isLoading && keerthane.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (filteredKeerthane.isEmpty && (_searchQuery != null && _searchQuery!.isNotEmpty))
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('lib/assets/lottie/search-empty.json', width: 200, height: 200),
                          const SizedBox(height: 16),
                          Text('No Keerthane found for "$_searchQuery".', style: textTheme.titleMedium, textAlign: TextAlign.center,),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8.0),
                      itemCount: filteredKeerthane.length,
                      itemBuilder: (context, index) {
                        final keerthaneItem = filteredKeerthane[index];
                        return _buildKeerthaneListTile(keerthaneItem, colorScheme, textTheme);
                      },
                    ),
                  if (_showScrollToTopButton)
                    Positioned(
                      bottom: 16,
                      right: 0,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _scrollToTop,
                        backgroundColor: colorScheme.tertiaryContainer,
                        foregroundColor: colorScheme.onTertiaryContainer,
                        elevation: 3.0,
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

  Widget _buildKeerthaneListTile(Keerthane keerthaneItem, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'lib/assets/icons/keerthane.png',
            ),
          ),
        ),
        title: Text(
          'Keerthane ${keerthaneItem.number}: ${keerthaneItem.title}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.secondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KeerthaneDetailScreen(keerthane: keerthaneItem)),
          );
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}
