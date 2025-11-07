import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/movie_provider.dart';
import '../../../data/models/movie_model.dart';

class UserFavoritesScreen extends StatefulWidget {
  const UserFavoritesScreen({super.key});

  @override
  State<UserFavoritesScreen> createState() => _UserFavoritesScreenState();
}

class _UserFavoritesScreenState extends State<UserFavoritesScreen> {
  late Future<List<MovieModel>> _favoriteMoviesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final movieProvider = context.read<MovieProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser != null) {
      movieProvider.loadFavorites(authProvider.currentUser!.uid);
      _favoriteMoviesFuture = movieProvider.getFavoriteMovies();
    }
  }

  void _refreshFavorites() {
    setState(() {
      final movieProvider = context.read<MovieProvider>();
      _favoriteMoviesFuture = movieProvider.getFavoriteMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        automaticallyImplyLeading: false,
        actions: [
          if (movieProvider.favoriteIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${movieProvider.favoriteIds.length} movies',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
      body: movieProvider.favoriteIds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add movies from the Home tab',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<MovieModel>>(
              future: _favoriteMoviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load favorites'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshFavorites,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final favoriteMovies = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = favoriteMovies[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Movie poster
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: movie.posterUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: movie.posterUrl,
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 80,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.movie),
                                      ),
                                    )
                                  : Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.movie),
                                    ),
                            ),
                            const SizedBox(width: 16),

                            // Movie details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    movie.releaseDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    movie.overview,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Remove button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove from favorites?'),
                                    content: Text('Remove "${movie.title}" from your favorites?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  final success = await movieProvider.toggleFavorite(
                                    authProvider.currentUser!.uid,
                                    movie.id,
                                  );

                                  if (context.mounted && success) {
                                    _refreshFavorites(); // Refresh the list
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Removed from favorites'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                }
                              },
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