import '../models/movie_model.dart';
import 'firestore_service.dart';

class MovieFirestoreService {
  final FirestoreService _firestore = FirestoreService();

  // Get all movies from Firestore
  Future<List<MovieModel>> getAllMovies() async {
    try {
      final moviesData = await _firestore.getAllDocuments('movies');
      return moviesData.map((data) => MovieModel.fromFirestore(data)).toList();
    } catch (e) {
      throw Exception('Error getting Firestore movies: $e');
    }
  }

  // Search movies in Firestore by title
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final moviesData = await _firestore.getAllDocuments('movies');
      final allMovies = moviesData.map((data) => MovieModel.fromFirestore(data)).toList();
      
      // Filter by title (case-insensitive)
      final filtered = allMovies.where((movie) {
        return movie.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      return filtered;
    } catch (e) {
      throw Exception('Error searching Firestore movies: $e');
    }
  }

  // Add new movie (admin only)
  Future<void> addMovie(MovieModel movie) async {
    try {
      await _firestore.createDocument('movies', movie.id, movie.toMap());
    } catch (e) {
      throw Exception('Error adding movie: $e');
    }
  }

  // Get movie by ID
  Future<MovieModel?> getMovieById(String movieId) async {
    try {
      final movieData = await _firestore.getDocument('movies', movieId);
      if (movieData == null) return null;
      return MovieModel.fromFirestore(movieData);
    } catch (e) {
      return null;
    }
  }
}