import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final ValueChanged<String> onChanged;
  final VoidCallback onQueryCleared;
  final FocusNode focusNode;

  const SearchBar({
    super.key,
    required this.hintText,
    this.hintStyle,
    required this.onChanged,
    required this.onQueryCleared,
    required this.focusNode,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSearching = _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Icon(Icons.search, color: Colors.black),
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _textController.clear();
                    widget.onQueryCleared();
                    setState(() => _isSearching = false);
                  },
                )
              : null,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? const TextStyle(),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
