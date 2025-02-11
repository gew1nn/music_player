import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'player_screen.dart';

class YourMusicScreen extends StatelessWidget {
  const YourMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;  // get the current authenticated user
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
      ),
      body: StreamBuilder<QuerySnapshot>(  // listen to changes in the 'favorites' collection of the current user
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {  // if no data or empty collection
            return const Center(child: Text('No favorite songs yet'));
          }
          final songs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index].data() as Map<String, dynamic>;  // extract song data as map
              return ListTile(
                leading: ClipRRect(
                  // leading widget for image display with rounded corners
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    song['cover'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,  // fit image to cover the box
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note),  // show music note icon if image fails to load
                  ),
                ),
                title: Text(song['title']),  // song title
                subtitle: Text(song['artist']),  // song artist
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerScreen(
                        songs: songs.map((doc) {
                          // pass the list of all songs to the player screen
                          final data = doc.data() as Map<String, dynamic>;
                          return {
                            'title': data['title'].toString(),
                            'artist': data['artist'].toString(),
                            'cover': data['cover'].toString(),
                            'url': data['url'].toString(),
                          };
                        }).toList(),
                        initialIndex: index,  // start the player at the tapped song's index
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
