import 'html_text.dart';

class TrackMetadata {
  final String title;
  final String artist;
  final String? label;
  final String? album;
  final String? year;
  final String? artworkSmall;
  final String? artworkLarge;
  final bool isNew;
  final bool isHit;

  TrackMetadata({
    required this.title,
    required this.artist,
    this.label,
    this.album,
    this.year,
    this.artworkSmall,
    this.artworkLarge,
    this.isNew = false,
    this.isHit = false,
  });

  /// Titolo seguito da album e anno, separati da " - ". Le parti mancanti vengono saltate.
  String get titleWithDetails => [title, album, year]
      .where((part) => part != null && part.isNotEmpty)
      .join(' - ');

  /// Album e anno separati da " - ", o stringa vuota se mancano entrambi.
  String get albumWithYear => [album, year]
      .where((part) => part != null && part.isNotEmpty)
      .join(' - ');

  static String? _optionalText(Object? value) {
    if (value == null) return null;
    final text = sanitizeHtmlText(value.toString()).trim();
    return text.isEmpty ? null : text;
  }

  factory TrackMetadata.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    return TrackMetadata(
      title: sanitizeHtmlText((result['metadataTitle'] ?? result['title'] ?? '').toString()),
      artist: sanitizeHtmlText((result['metadataArtist'] ?? result['artist'] ?? '').toString()),
      label: result['label']?.toString(),
      album: _optionalText(result['album']),
      year: _optionalText(result['year']),
      artworkSmall: result['artworkSmall']?.toString(),
      artworkLarge: result['artworkLarge']?.toString(),
      isNew: result['isNew'] == true,
      isHit: result['isHit'] == true,
    );
  }

  factory TrackMetadata.empty() =>
      TrackMetadata(title: 'Radio Wah', artist: '');
}
