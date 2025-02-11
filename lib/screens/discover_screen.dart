import 'package:audio_player/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audio_player/services/spotify_auth.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<dynamic> tracks = []; // list to hold tracks

  @override
  void initState() {
    super.initState();
    fetchTracks(); // if token is not available, exit
  }

  Future<void> fetchTracks() async {
    String? token = await SpotifyAuth.getAccessToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/new-releases'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        tracks = jsonDecode(response.body)['albums']['items'];
      });
    } else {
      print('Ошибка: ${response.body}');
    }
  }

  @override
  // building each item in the list
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover new releases')),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return ListTile(
            title: Text(track['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // navigating to the WebView screen
                  builder: (context) => WebViewContainer(
                    url: track['external_urls']['spotify'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}