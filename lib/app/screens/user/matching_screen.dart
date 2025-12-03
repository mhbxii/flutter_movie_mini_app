import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/movie_provider.dart';
import '../../../providers/matching_provider.dart';
import '../../../data/models/movie_model.dart';

class UserMatchingScreen extends StatefulWidget {
  const UserMatchingScreen({super.key});

  @override
  State<UserMatchingScreen> createState() => _UserMatchingScreenState();
}

class _UserMatchingScreenState extends State<UserMatchingScreen> {
  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final authProvider = context.read<AuthProvider>();
    final movieProvider = context.read<MovieProvider>();
    final matchingProvider = context.read<MatchingProvider>();

    if (authProvider.currentUser != null) {
      await movieProvider.loadFavorites(authProvider.currentUser!.uid);
      await matchingProvider.findMatches(
        authProvider.currentUser!.uid,
        movieProvider.favoriteIds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final matchingProvider = context.watch<MatchingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
            tooltip: 'Refresh',
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
                    'Add movies to find matches',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : matchingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : matchingProvider.matches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No matches found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have ${movieProvider.favoriteIds.length} favorites',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'No users with 75%+ match yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header info
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${movieProvider.favoriteIds.length} favorites • ${matchingProvider.matches.length} matches found',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        // Matches list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: matchingProvider.matches.length,
                            itemBuilder: (context, index) {
                              final match = matchingProvider.matches[index];
                              return _MatchCard(
                                match: match,
                                movieProvider: movieProvider,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _MatchCard extends StatefulWidget {
  final dynamic match;
  final MovieProvider movieProvider;

  const _MatchCard({
    required this.match,
    required this.movieProvider,
  });

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> {
  bool _isExpanded = false;
  List<MovieModel>? _commonMovies;
  bool _isLoadingMovies = false;

  Future<void> _loadCommonMovies() async {
    if (_commonMovies != null) return;

    setState(() => _isLoadingMovies = true);

    try {
      final movies = <MovieModel>[];
      for (final movieId in widget.match.commonMovieIds) {
        try {
          final movie = await widget.movieProvider.getFavoriteMovieById(movieId);
          if (movie != null) movies.add(movie);
        } catch (e) {
          continue;
        }
      }
      if (mounted) {
        setState(() {
          _commonMovies = movies;
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMovies = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.match.user;
    final matchPercentage = widget.match.matchPercentage.toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            title: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('Age: ${user.age}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.match.commonMovieIds.length} common',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Expandable section
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              if (_isExpanded) _loadCommonMovies();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Hide common movies' : 'Show common movies',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Common movies list
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              child: _isLoadingMovies
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _commonMovies == null || _commonMovies!.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Unable to load movies',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonMovies!.map((movie) {
                            return Chip(
                              avatar: movie.posterUrl.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(movie.posterUrl),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.movie, size: 16),
                                    ),
                              label: Text(
                                movie.title,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
            ),
        ],
      ),
    );
  }
}