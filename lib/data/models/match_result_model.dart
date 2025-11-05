import 'user_model.dart';

class MatchResultModel {
  final UserModel user;
  final double matchPercentage;
  final List<String> commonMovieIds;

  MatchResultModel({
    required this.user,
    required this.matchPercentage,
    required this.commonMovieIds,
  });
}