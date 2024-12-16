// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Featured Artworks Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Text(
                    'Featured Artworks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            FeaturedArtworks(),
            
            // Trending Artists Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Text(
                    'Trending Artists',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            TrendingArtists(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is the first tab
        onTap: (index) {
          switch(index){
            case 0:
              // Already on Home
              break;
            case 1:
              Navigator.pushNamed(context, '/gallery');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
            case 3:
              Navigator.pushNamed(context, '/chat');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.art_track),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}

class FeaturedArtworks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return SizedBox(
      height: 250,
      child: StreamBuilder<List<Artwork>>(
        stream: firestoreService.getFeaturedArtworks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading featured artworks'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final artworks = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              final artwork = artworks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile', arguments: artwork);
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.network(
                        artwork.imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          artwork.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('\$${artwork.price.toStringAsFixed(2)} ${artwork.currency}'),
                    ],
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

class TrendingArtists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return SizedBox(
      height: 150,
      child: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getTrendingArtists(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trending artists'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final artists = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile', arguments: artist.id);
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(artist.profilePicture),
                        radius: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          artist.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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