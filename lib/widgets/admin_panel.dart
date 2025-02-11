import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A stateful widget representing the admin panel for managing songs.
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  // Controllers to handle user input for song details.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // Adds a new song to the Firestore collection 'songs'.
  Future<void> _addSong() async {
    await FirebaseFirestore.instance.collection('songs').add({
      'title': _titleController.text.trim(),
      'artist': _artistController.text.trim(),
      'cover': _coverController.text.trim(),
      'url': _urlController.text.trim(),
    });

    // Clears the input fields after adding the song.
    _titleController.clear();
    _artistController.clear();
    _coverController.clear();
    _urlController.clear();
  }

  // Deletes a song from Firestore using its document ID.
  Future<void> _deleteSong(String songId) async {
    await FirebaseFirestore.instance.collection('songs').doc(songId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Admin panel')), // Admin panel title.
      body: Column(
        children: [
          // Input fields for adding a new song.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white)),
                ),
                TextField(
                  controller: _artistController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Artist', labelStyle: TextStyle(color: Colors.white)),
                ),
                TextField(
                  controller: _coverController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'URL cover', labelStyle: TextStyle(color: Colors.white)),
                ),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'URL song', labelStyle: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addSong, // Calls the function to add a new song.
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Add song'),
                ),
              ],
            ),
          ),
          // Displays the list of songs from Firestore.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final songs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index].data() as Map<String, dynamic>;
                    final songId = songs[index].id;

                    // Checks if cover or URL are missing.
                    final bool isCoverMissing = song['cover']?.toString().isEmpty ?? true;
                    final bool isUrlMissing = song['url']?.toString().isEmpty ?? true;
                    final bool isArtistMissing = song['artist']?.toString().isEmpty ?? true;
                    final bool isTitleMissing = song['title']?.toString().isEmpty ?? true;

                    // Uses a default cover if no URL is provided.
                    final String cover = isCoverMissing
                        ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Music_Icon.svg/512px-Music_Icon.svg.png'
                        : song['cover'];

                    // Highlights missing data with a red background.
                    final Color tileColor = (isCoverMissing || isUrlMissing || isArtistMissing || isTitleMissing)
                        ? Colors.red.withRed(255)
                        : Colors.transparent;

                    return Container(
                      color: tileColor,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: isCoverMissing
                              ? const Icon(Icons.music_note, size: 50, color: Colors.white)
                              : Image.network(
                            cover,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.music_note, size: 50, color: Colors.white),
                          ),
                        ),
                        title: isTitleMissing
                            ? const Text('Title is missing', style: TextStyle(color: Colors.white))
                            : Text(song['title'], style: const TextStyle(color: Colors.white)),
                        subtitle: isArtistMissing
                            ? const Text('Artist is missing', style: TextStyle(color: Colors.white70))
                            : Text(song['artist'], style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteSong(songId), // deletes the selected song
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
