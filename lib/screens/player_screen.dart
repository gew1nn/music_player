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

// state class for MusicPlayerScreen
class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;  // to handle playback
  int _currentIndex = 0;  // to track the current song index

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _setupListeners();
    _playCurrentSong();
  }

  void _setupListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _nextSong();
      }
    });
  }

  // method to play the current song
  Future<void> _playCurrentSong() async {
    try {
      final song = widget.songs[_currentIndex];
      final String url = song['url']?.toString().isNotEmpty == true
          ? song['url']
          : 'https://file-examples.com/storage/fe21422a6d67aa28993b797/2017/11/file_example_MP3_700KB.mp3';  // fallback URL if not

      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play song: ${e.toString()}')),
        // show error message if playback fails
      );
    }
  }

  // method to play the next song
  Future<void> _nextSong() async {
    if (widget.songs.isNotEmpty) {  // check if there are any songs
      await _audioPlayer.stop();  // stop the current song
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.songs.length;  // move to next song, loop if necessary
      });
      await _playCurrentSong();  // play the next song
    }
  }
  // method to play the previous song
  Future<void> _previousSong() async {
    if (widget.songs.isNotEmpty) {
      await _audioPlayer.stop();
      setState(() {
        _currentIndex = (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
      });
      await _playCurrentSong();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();  // clean up the audio player
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
                currentSong['cover']?.toString().isNotEmpty == true
                    ? currentSong['cover']
                    : 'https://cdn.creazilla.com/icons/3431524/music-icon-md.png',  // fallback image if cover is not available
                width: 300,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.music_note, size: 100, color: Colors.white),  // show music note icon on error
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentSong['title']?.toString() ?? 'No Title',  // display song title
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              currentSong['artist']?.toString() ?? 'No Artist',  // display artist name
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;  // get the current position
                final totalDuration = _audioPlayer.duration ?? Duration.zero;  // get the total duration of the song

                //function to form mm:ss
                String formatDuration(Duration duration) {
                  int minutes = duration.inMinutes;
                  int seconds = duration.inSeconds % 60;

                  return '$minutes:${seconds.toString().padLeft(2, '0')}';
                }
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
                      '${formatDuration(position)} / ${formatDuration(totalDuration)}', // displays mm:ss
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // place buttons evenly across the row
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 48, color: Colors.green),  // previous song button
                  onPressed: _previousSong,  // trigger previous song method
                ),
                StreamBuilder<PlayerState>(  // the audio player's state (playing or paused)
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data?.playing ?? false;  // check if the song is currently playing
                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,  // change icon based on playback state
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
                  onPressed: _nextSong,  // trigger next song method
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
