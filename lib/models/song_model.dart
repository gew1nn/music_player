class SpotifySong {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String imageUrl;
  final int durationMs;
  final int popularity;
  final String spotifyUrl;

  SpotifySong({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.durationMs,
    required this.popularity,
    required this.spotifyUrl,
  });

  String get formattedDuration {
    final minutes = (durationMs ~/ 60000).toString();
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  factory SpotifySong.fromJson(Map<String, dynamic> json) {
    return SpotifySong(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artist: (json['artists'] as List?)?.map((artist) => artist['name']).join(', ') ?? 'Unknown Artist',
      album: json['album']?['name'] ?? 'Unknown Album',
      imageUrl: (json['album']?['images'] as List?)?.isNotEmpty == true
          ? json['album']['images'][0]['url']
          : '',
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'] ?? 0,
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
    );
  }
}
