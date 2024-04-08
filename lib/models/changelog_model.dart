class ChangelogEntry {
  final String title;
  final String version;
  final String date;
  final List<String> changes;

  ChangelogEntry({
    required this.title,
    required this.version,
    required this.date,
    required this.changes,
  });

  factory ChangelogEntry.fromJson(Map<String, dynamic> json) {
    return ChangelogEntry(
      title: json['title'] as String,
      version: json['version'] as String,
      date: json['date'] as String,
      changes: (json['changes'] as List).map((change) => change as String).toList(),
    );
  }
}
