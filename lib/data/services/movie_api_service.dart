import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieApiService {
  static const String _apiKey = 'bb5e2ed62f2ea1d6c949d5ce38b6ea1e';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Search movies by query
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieModel.fromApi(json)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  // Get popular movies
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieModel.fromApi(json)).toList();
      } else {
        throw Exception('Failed to get popular movies');
      }
    } catch (e) {
      throw Exception('Error getting popular movies: $e');
    }
  }

  // Get movie details by ID
  Future<MovieModel> getMovieDetails(String movieId) async {
    try {
      final url = Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieModel.fromApi(data);
      } else {
        throw Exception('Failed to get movie details');
      }
    } catch (e) {
      throw Exception('Error getting movie details: $e');
    }
  }
}