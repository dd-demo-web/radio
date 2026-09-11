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

  factory TrackMetadata.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    return TrackMetadata(
      title: (result['metadataTitle'] ?? result['title'] ?? '').toString(),
      artist: (result['metadataArtist'] ?? result['artist'] ?? '').toString(),
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
