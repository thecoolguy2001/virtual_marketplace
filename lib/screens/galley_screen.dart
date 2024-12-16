// lib/screens/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/artwork.dart';
import 'profile_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);
  
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Filter variables
  String? selectedCategory;
  double? minPrice;
  double? maxPrice;
  String? selectedArtist;

  // Controllers for price inputs
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // List of categories and artists (populate dynamically or statically)
  final List<String> categories = ['All', 'Painting', 'Illustration', 'Photography', 'Digital', 'Other'];
  List<String> artists = ['All']; // Populate from Firestore

  @override
  void initState() {
    super.initState();
    // Fetch list of artists from Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchArtists();
    });
  }

  Future<void> _fetchArtists() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    // Fetch all unique artist names or IDs
    // Assuming UserModel has name and id
    QuerySnapshot snapshot = await firestoreService._db.collection('Users').get();
    List<String> artistNames = snapshot.docs.map((doc) {
      Map data = doc.data() as Map<String, dynamic>;
      return data['name'] ?? 'Unknown';
    }).toSet().toList(); // Remove duplicates
    setState(() {
      artists = ['All'] + artistNames;
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      selectedCategory = selectedCategory == 'All' ? null : selectedCategory;
      selectedArtist = selectedArtist == 'All' ? null : selectedArtist;
      minPrice = _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
      maxPrice = _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedArtist = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      minPrice = null;
      maxPrice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filter Artworks',
          ),
        ],
      ),
      body: StreamBuilder<List<Artwork>>(
        stream: firestoreService.getFilteredArtworks(
          category: selectedCategory,
          minPrice: minPrice,
          maxPrice: maxPrice,
          // artistId: selectedArtistId, // Adjust based on your Firestore structure
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading artworks'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final artworks = snapshot.data!;
          if (artworks.isEmpty) {
            return const Center(child: Text('No artworks found with the selected filters.'));
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: artworks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Adjust for responsiveness
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final artwork = artworks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(artistId: artwork.artistId),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Artwork Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              artwork.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ),
                        // Artwork Details
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            artwork.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '\$${artwork.price.toStringAsFixed(2)} ${artwork.currency}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearFilters,
        tooltip: 'Clear Filters',
        child: const Icon(Icons.clear),
      ),
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSelectedCategory = selectedCategory ?? 'All';
        String? tempSelectedArtist = selectedArtist ?? 'All';
        TextEditingController tempMinPriceController = TextEditingController(text: _minPriceController.text);
        TextEditingController tempMaxPriceController = TextEditingController(text: _maxPriceController.text);

        return AlertDialog(
          title: const Text('Filter Artworks'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: tempSelectedCategory ?? 'All',
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (val) {
                    tempSelectedCategory = val;
                  },
                ),
                const SizedBox(height: 10),
                // Artist Dropdown
                DropdownButtonFormField<String>(
                  value: tempSelectedArtist ?? 'All',
                  decoration: const InputDecoration(labelText: 'Artist'),
                  items: artists.map((artist) {
                    return DropdownMenuItem<String>(
                      value: artist,
                      child: Text(artist),
                    );
                  }).toList(),
                  onChanged: (val) {
                    tempSelectedArtist = val;
                  },
                ),
                const SizedBox(height: 10),
                // Price Range Inputs
                TextFormField(
                  controller: tempMinPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Min Price',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: tempMaxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Max Price',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update filters
                setState(() {
                  selectedCategory = tempSelectedCategory == 'All' ? null : tempSelectedCategory;
                  selectedArtist = tempSelectedArtist == 'All' ? null : tempSelectedArtist;
                  minPrice = tempMinPriceController.text.isNotEmpty ? double.tryParse(tempMinPriceController.text) : null;
                  maxPrice = tempMaxPriceController.text.isNotEmpty ? double.tryParse(tempMaxPriceController.text) : null;
                });
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}