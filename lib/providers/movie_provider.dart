import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';
import '../data/services/firestore_service.dart';

class MovieProvider with ChangeNotifier {
  final MovieApiService _apiService = MovieApiService();
  final FirestoreService _firestore = FirestoreService();

  List<MovieModel> _movies = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MovieModel> get movies => _movies;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if movie is favorited
  bool isFavorite(String movieId) => _favoriteIds.contains(movieId);

  // Load user's favorites from Firestore
  Future<void> loadFavorites(String userId) async {
    try {
      final userData = await _firestore.getDocument('users', userId);
      if (userData != null) {
        _favoriteIds = List<String>.from(userData['favoriteMovies'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load favorites';
    }
  }

  // Get popular movies
  Future<void> getPopularMovies() async {
    _setLoading(true);
    _clearError();

    try {
      _movies = await _apiService.getPopularMovies();
    } catch (e) {
      _errorMessage = 'Failed to load movies: $e';
      _movies = [];
    } finally {
      _setLoading(false);
    }
  }

  // Search movies
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      await getPopularMovies();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _movies = await _apiService.searchMovies(query);
    } catch (e) {
      _errorMessage = 'Failed to search movies: $e';
      _movies = [];
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite (add or remove)
  Future<bool> toggleFavorite(String userId, String movieId) async {
    try {
      final isFav = _favoriteIds.contains(movieId);
      
      if (isFav) {
        // Remove from favorites
        _favoriteIds.remove(movieId);
      } else {
        // Add to favorites
        _favoriteIds.add(movieId);
      }

      // Update Firestore with timestamp
      await _firestore.updateDocument('users', userId, {
        'favoriteMovies': _favoriteIds,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update favorites: $e';
      // Revert the change
      final isFav = _favoriteIds.contains(movieId);
      if (isFav) {
        _favoriteIds.remove(movieId);
      } else {
        _favoriteIds.add(movieId);
      }
      notifyListeners();
      return false;
    }
  }

  // Add this method to your MovieProvider class

  // Get single favorite movie by ID (for matching screen)
  Future<MovieModel?> getFavoriteMovieById(String movieId) async {
    try {
      return await _apiService.getMovieDetails(movieId);
    } catch (e) {
      return null;
    }
  }

  // Get favorite movies details
  Future<List<MovieModel>> getFavoriteMovies() async {
    if (_favoriteIds.isEmpty) return [];

    _setLoading(true);
    _clearError();

    try {
      final favoriteMovies = <MovieModel>[];
      
      for (final movieId in _favoriteIds) {
        try {
          final movie = await _apiService.getMovieDetails(movieId);
          favoriteMovies.add(movie);
        } catch (e) {
          // Skip movies that fail to load
          continue;
        }
      }

      _setLoading(false);
      return favoriteMovies;
    } catch (e) {
      _errorMessage = 'Failed to load favorite movies';
      _setLoading(false);
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}