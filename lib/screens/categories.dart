import 'package:flutter/material.dart';
import 'package:hymns_latest/categories/dynamic_category_screen.dart';

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
                _buildCategory(context, "Birthday", [361], [215]),
                _buildCategory(context, "Marriage", [358, 359, 360], [188, 189, 190]),
                _buildCategory(context, "House Warming", [362], [227, 228, 229, 230, 231, 232, 233, 234]),
                _buildCategory(context, "Funeral", [], []),
                _buildCategory(context, "Mangala", null, [227, 228, 229, 230, 231, 232, 233, 234]),
                _buildCategory(context, "Children's Prayer", [328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349], [200, 201, 202, 203, 204, 205, 206, 207, 208, 209]),
                _buildCategory(context, "Lord's Supper", [273, 274, 275, 276, 277, 278, 279], [184, 185, 186, 187]),
                _buildCategory(context, "Travelling", [363], []),
                _buildCategory(context, "Sickness", [367], []),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String category, List<int>? hymnNumbers, List<int>? keerthaneNumbers) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DynamicCategoryScreen(
              category: category,
              hymnNumbers: hymnNumbers,
              keerthaneNumbers: keerthaneNumbers,
            ),
          ),
        );
      },
      child: Chip(
        label: Text(
          category,
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}
