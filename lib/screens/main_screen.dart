import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'music_screen.dart';
import 'discover_screen.dart';
import 'package:audio_player/widgets/auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  final List<Widget> _screens = [
    const HomeScreen(),
    const YourMusicScreen(),
    const DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {  // if no log in
          return const AuthScreen();
        }
        return Scaffold(  // if logged in
          body: Stack(
            children: [
              _screens[_currentIndex],  // display the currently selected screen
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.white54,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;  // update the index to switch the screen
              });
            },
            items: const [  // defining the items (icons and labels) for the navigation bar
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Your Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'New releases',
              ),
            ],
          ),
        );
      },
    );
  }
}
