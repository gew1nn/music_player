import 'package:flutter/material.dart';
import 'package:audio_player/models/song_model.dart';

class SongDetailsScreen extends StatelessWidget {
  final SpotifySong song;

  const SongDetailsScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(song.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(song.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(song.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Artist: ${song.artist}', style: const TextStyle(fontSize: 18)),
            Text('Album: ${song.album}', style: const TextStyle(fontSize: 18)),
            Text('Duration: ${Duration(milliseconds: song.durationMs).inMinutes} min', style: const TextStyle(fontSize: 18)),
            Text('Popularity: ${song.popularity}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
