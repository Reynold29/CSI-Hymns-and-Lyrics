import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Common Hymns",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildCategoryLabel(context, "Birthday"),
                _buildCategoryLabel(context, "Marriage"),
                _buildCategoryLabel(context, "House Warming"),
                _buildCategoryLabel(context, "Funeral"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(BuildContext context, String categoryName) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryHymnScreen(category: categoryName),
          ),
        );
      },
      child: Chip(
        label: Text(categoryName, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)), // Text color based on theme
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Background color based on theme
      ),
    );
  }
}

class CategoryHymnScreen extends StatefulWidget {
  final String category;
  const CategoryHymnScreen({super.key, required this.category});

  @override
  _CategoryHymnScreenState createState() => _CategoryHymnScreenState();
}

class _CategoryHymnScreenState extends State<CategoryHymnScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.category} Hymns & Keerthanes'), // Dynamic title with category
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Hymns'),
              Tab(text: 'Keerthanes'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Hymn list placeholder for Category
            Center(child: Text('Hymns for ${widget.category} - Coming Soon!')),
            // Keerthane list placeholder for Category
            Center(child: Text('Keerthanes for ${widget.category} - Coming Soon!')),
          ],
        ),
      ),
    );
  }
}