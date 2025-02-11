import 'package:audio_player/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // profile icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // for the real-time updates in firebase
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Displays a message if no songs are found.
            return const Center(child: Text('No songs found'));
          }
          // firebase documents into songs
          final songs = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SongTile(
                songsList: songs,
                initialIndex: index,
              );
            },
          );
        },
      ),
    );
  }
}

// a widget representing a single song
class SongTile extends StatefulWidget {
  final List<Map<String, dynamic>> songsList;
  final int initialIndex;

  const SongTile({
    super.key,
    required this.songsList,
    required this.initialIndex,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // check if the song is in favourites
  }

  // checks if the current song is in the user's favorites
  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favorites = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('url', isEqualTo: widget.songsList[widget.initialIndex]['url'])
          .get();

      setState(() {
        _isFavorite = favorites.docs.isNotEmpty;
      });
    }
  }

  // toggles the favorite status of the song.
  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favorites = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('url', isEqualTo: widget.songsList[widget.initialIndex]['url'])
          .get();

      if (favorites.docs.isEmpty) {
        // if not already a favorite, add it.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .add(widget.songsList[widget.initialIndex]);
      } else {
        // if already a favorite, remove it.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(favorites.docs.first.id)
            .delete();
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songsList[widget.initialIndex];

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          song['cover'], // cover image.
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.music_note), // shows a music icon if the image fails to load.
        ),
      ),
      title: Text(song['title']), // song title.
      subtitle: Text(song['artist']), // artist name.
      trailing: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border, // favorite/unfavorite icon.
          color: _isFavorite ? Colors.red : Colors.white,
        ),
        onPressed: _toggleFavorite, // toggles the favorite status.
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              songs: widget.songsList,
              initialIndex: widget.initialIndex,
            ),
          ),
        );
      },
    );
  }
}
