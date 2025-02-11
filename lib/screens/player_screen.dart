import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
class MusicPlayerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final int initialIndex;

  const MusicPlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _playCurrentSong();
  }

  Future<void> _playCurrentSong() async {
    try {
      final song = widget.songs[_currentIndex];
      await _audioPlayer.setUrl(song['url']?.toString() ?? '');
      _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play song: ${e.toString()}')),
      );
    }
  }

  void _nextSong() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
    });
    _playCurrentSong();
  }

  void _previousSong() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
    });
    _playCurrentSong();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSong['title']?.toString() ?? 'No Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                currentSong['cover']?.toString() ?? '',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.music_note, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentSong['title']?.toString() ?? 'No Title',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              currentSong['artist']?.toString() ?? 'No Artist',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final totalDuration = _audioPlayer.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: totalDuration.inSeconds.toDouble().clamp(1.0, double.infinity),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Text(
                      '${position.toString().split('.').first} / ${totalDuration.toString().split('.').first}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 48, color: Colors.green),
                  onPressed: _previousSong,
                ),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 64,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 48, color: Colors.green),
                  onPressed: _nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}