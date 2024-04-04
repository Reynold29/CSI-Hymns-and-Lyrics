class Hymn {
  final int number;
  final String title; 
  final String signature;
  final String lyrics;
  final String? kannadaLyrics;

  Hymn({
    required this.number,
    required this.title, 
    required this.signature,
    required this.lyrics,
    this.kannadaLyrics,
  });
}
