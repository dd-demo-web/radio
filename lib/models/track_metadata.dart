class TrackMetadata {
  final String title;
  final String artist;
  final String? label;
  final String? artworkSmall;
  final String? artworkLarge;
  final bool isNew;
  final bool isHit;

  TrackMetadata({
    required this.title,
    required this.artist,
    this.label,
    this.artworkSmall,
    this.artworkLarge,
    this.isNew = false,
    this.isHit = false,
  });

  static String _sanitizeText(String text) {
    // First decode HTML entities
    String decoded = text;
    // Common HTML entities
    final entities = {
      '&egrave;': 'è',
      '&eacute;': 'é',
      '&agrave;': 'à',
      '&eacute;': 'é',
      '&igrave;': 'ì',
      '&ograve;': 'ò',
      '&ugrave;': 'ù',
      '&Egrave;': 'È',
      '&Eacute;': 'É',
      '&Agrave;': 'À',
      '&Igrave;': 'Ì',
      '&Ograve;': 'Ò',
      '&Ugrave;': 'Ù',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&apos;': "'",
      '&nbsp;': ' ',
    };
    for (final entry in entities.entries) {
      decoded = decoded.replaceAll(entry.key, entry.value);
    }
    
    // Then replace special unicode characters
    return decoded
        .replaceAll('\u2018', "'") // Left single quotation mark
        .replaceAll('\u2019', "'") // Right single quotation mark
        .replaceAll('\u201C', '"') // Left double quotation mark
        .replaceAll('\u201D', '"') // Right double quotation mark
        .replaceAll('\u2026', '...') // Ellipsis
        .replaceAll('\u2013', '-') // En dash
        .replaceAll('\u2014', '-'); // Em dash
  }

  factory TrackMetadata.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    return TrackMetadata(
      title: _sanitizeText((result['metadataTitle'] ?? result['title'] ?? '').toString()),
      artist: _sanitizeText((result['metadataArtist'] ?? result['artist'] ?? '').toString()),
      label: result['label']?.toString(),
      artworkSmall: result['artworkSmall']?.toString(),
      artworkLarge: result['artworkLarge']?.toString(),
      isNew: result['isNew'] == true,
      isHit: result['isHit'] == true,
    );
  }

  factory TrackMetadata.empty() =>
      TrackMetadata(title: 'Radio Wah', artist: '');
}
