import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final ValueChanged<String> onChanged;
  final VoidCallback onQueryCleared;
  final FocusNode focusNode;
  final Color? backgroundColor;
  final Color? searchIconColor;
  final Color? clearIconColor;
  final TextStyle? textStyle;

  const SearchBar({
    super.key,
    required this.hintText,
    this.hintStyle,
    required this.onChanged,
    required this.onQueryCleared,
    required this.focusNode,
    this.backgroundColor,
    this.searchIconColor,
    this.clearIconColor,
    this.textStyle,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _isSearching = _textController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        // _isSearching = widget.focusNode.hasFocus; // Keep _isSearching based on text content
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultTextStyle = theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface);
    final effectiveTextStyle = widget.textStyle ?? defaultTextStyle;
    final effectiveHintStyle = widget.hintStyle ?? theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant);
    final effectiveBackgroundColor = widget.backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.7);
    final effectiveSearchIconColor = widget.searchIconColor ?? colorScheme.onSurfaceVariant;
    final effectiveClearIconColor = widget.clearIconColor ?? colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: TextField(
        controller: _textController,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Icon(Icons.search, color: effectiveSearchIconColor),
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(Icons.clear, color: effectiveClearIconColor),
                  onPressed: () {
                    _textController.clear();
                    widget.onQueryCleared();
                  },
                )
              : null,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: effectiveHintStyle,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        ),
        style: effectiveTextStyle,
      ),
    );
  }
}
