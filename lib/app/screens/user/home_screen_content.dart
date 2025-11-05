import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/movie_provider.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = context.read<MovieProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // Load user favorites and popular movies
      if (authProvider.currentUser != null) {
        movieProvider.loadFavorites(authProvider.currentUser!.uid);
      }
      movieProvider.getPopularMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<MovieProvider>().searchMovies(query);
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Movies'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _handleSearch,
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Movies grid
          Expanded(
            child: movieProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movieProvider.movies.isEmpty
                    ? const Center(child: Text('No movies found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: movieProvider.movies.length,
                        itemBuilder: (context, index) {
                          final movie = movieProvider.movies[index];
                          final isFavorite = movieProvider.isFavorite(movie.id);

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Movie poster
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Poster image
                                      movie.posterUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: movie.posterUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.movie, size: 50),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(Icons.movie, size: 50),
                                              ),
                                            ),

                                      // Favorite button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 18,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? Colors.red : Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              // Check if user is logged in
                                              if (authProvider.currentUser == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please login first'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }

                                              final success = await movieProvider.toggleFavorite(
                                                authProvider.currentUser!.uid,
                                                movie.id,
                                              );

                                              if (context.mounted && success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isFavorite
                                                          ? 'Removed from favorites'
                                                          : 'Added to favorites',
                                                    ),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              } else if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Failed to update favorites'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Movie title
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}