import '../models/user_model.dart';
import '../models/match_result_model.dart';
import 'firestore_service.dart';

class MatchingService {
  final FirestoreService _firestore = FirestoreService();

  // Find users with 75%+ match
  Future<List<MatchResultModel>> findMatches(String currentUserId, List<String> currentUserFavorites) async {
    if (currentUserFavorites.isEmpty) return [];

    try {
      // Get all active users except current user
      final usersData = await _firestore.queryDocuments('users', whereField: 'isActive', whereValue: true);
      
      final matches = <MatchResultModel>[];

      for (var userData in usersData) {
        final user = UserModel.fromMap(userData);
        
        // Skip current user
        if (user.uid == currentUserId) continue;
        
        // Skip users with no favorites
        if (user.favoriteMovies.isEmpty) continue;

        // Calculate match percentage
        final commonMovies = currentUserFavorites.where((id) => user.favoriteMovies.contains(id)).toList();
        
        // Total unique movies between both users
        final allMovies = {...currentUserFavorites, ...user.favoriteMovies};
        
        // Match percentage: common / total unique * 100
        final matchPercentage = (commonMovies.length / allMovies.length) * 100;

        // Only include if match is 75% or higher
        if (matchPercentage >= 75.0) {
          matches.add(MatchResultModel(
            user: user,
            matchPercentage: matchPercentage,
            commonMovieIds: commonMovies,
          ));
        }
      }

      // Sort by match percentage (highest first)
      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      return matches;
    } catch (e) {
      throw Exception('Error finding matches: $e');
    }
  }
}