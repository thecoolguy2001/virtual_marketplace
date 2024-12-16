// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/artwork.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String artistId;

  const ProfileScreen({Key? key, required this.artistId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return FutureBuilder<UserModel>(
      future: firestoreService.getUserById(artistId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Artist Profile')),
            body: const Center(child: Text('Error loading artist profile')),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Artist Profile')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final artist = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(artist.name),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Artist Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(artist.profilePicture),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 16),
                      // Artist Name
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Artist Bio (Assuming there's a 'bio' field)
                      Text(
                        artist.bio ?? 'No bio available.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      // Chat Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(artistId: artist.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat with Artist'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Artist's Artworks
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Text(
                        'Portfolio',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<List<Artwork>>(
                  stream: firestoreService.getArtworksByArtist(artist.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading artworks'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final artworks = snapshot.data!;
                    if (artworks.isEmpty) {
                      return const Center(child: Text('No artworks to display.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: artworks.length,
                      itemBuilder: (context, index) {
                        final artwork = artworks[index];
                        return ListTile(
                          leading: Image.network(
                            artwork.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                          title: Text(artwork.title),
                          subtitle: Text('\$${artwork.price.toStringAsFixed(2)} ${artwork.currency}'),
                          onTap: () {
                            // Navigate to detailed artwork view or initiate purchase/chat
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}