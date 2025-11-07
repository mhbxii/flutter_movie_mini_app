import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';
import '../data/services/movie_firestore_service.dart';
import '../data/services/firestore_service.dart';

class MovieProvider with ChangeNotifier {
  final MovieApiService _apiService = MovieApiService();
  final MovieFirestoreService _firestoreMovieService = MovieFirestoreService();
  final FirestoreService _firestore = FirestoreService();

  List<MovieModel> _movies = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MovieModel> get movies => _movies;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String movieId) => _favoriteIds.contains(movieId);

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

  // Get popular movies - parallel loading from both sources
  Future<void> getPopularMovies() async {
    _setLoading(true);
    _clearError();
    _movies = []; // Clear existing movies
    notifyListeners();

    // Launch both requests in parallel
    _fetchApiMovies();
    _fetchFirestoreMovies();
  }

  void _fetchApiMovies() async {
    try {
      final apiMovies = await _apiService.getPopularMovies();
      _movies.addAll(apiMovies);
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load API movies: $e';
      _setLoading(false);
    }
  }

  void _fetchFirestoreMovies() async {
    try {
      final firestoreMovies = await _firestoreMovieService.getAllMovies();
      _movies.addAll(firestoreMovies);
      notifyListeners();
    } catch (e) {
      // Silently fail for Firestore movies
    }
  }

  // Search movies - parallel loading from both sources
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      await getPopularMovies();
      return;
    }

    _setLoading(true);
    _clearError();
    _movies = [];
    notifyListeners();

    // Launch both searches in parallel
    _searchApiMovies(query);
    _searchFirestoreMovies(query);
  }

  void _searchApiMovies(String query) async {
    try {
      final apiMovies = await _apiService.searchMovies(query);
      _movies.addAll(apiMovies);
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to search API movies: $e';
      _setLoading(false);
    }
  }

  void _searchFirestoreMovies(String query) async {
    try {
      final firestoreMovies = await _firestoreMovieService.searchMovies(query);
      _movies.addAll(firestoreMovies);
      notifyListeners();
    } catch (e) {
      // Silently fail for Firestore movies
    }
  }

  Future<bool> toggleFavorite(String userId, String movieId) async {
    try {
      final isFav = _favoriteIds.contains(movieId);
      
      if (isFav) {
        _favoriteIds.remove(movieId);
      } else {
        _favoriteIds.add(movieId);
      }

      await _firestore.updateDocument('users', userId, {
        'favoriteMovies': _favoriteIds,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update favorites: $e';
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

  Future<MovieModel?> getFavoriteMovieById(String movieId) async {
    try {
      // Try API first
      return await _apiService.getMovieDetails(movieId);
    } catch (e) {
      // Try Firestore if API fails
      try {
        return await _firestoreMovieService.getMovieById(movieId);
      } catch (e) {
        return null;
      }
    }
  }

  Future<List<MovieModel>> getFavoriteMovies() async {
    if (_favoriteIds.isEmpty) return [];

    _setLoading(true);
    _clearError();

    try {
      final favoriteMovies = <MovieModel>[];
      
      for (final movieId in _favoriteIds) {
        final movie = await getFavoriteMovieById(movieId);
        if (movie != null) {
          favoriteMovies.add(movie);
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