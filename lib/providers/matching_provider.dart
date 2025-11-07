import 'package:flutter/material.dart';
import '../data/models/match_result_model.dart';
import '../data/services/matching_service.dart';

class MatchingProvider with ChangeNotifier {
  final MatchingService _matchingService = MatchingService();

  List<MatchResultModel> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MatchResultModel> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Find matches for current user
  Future<void> findMatches(String userId, List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      _matches = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _matches = await _matchingService.findMatches(userId, favoriteIds);
    } catch (e) {
      _errorMessage = 'Failed to find matches: $e';
      _matches = [];
    } finally {
      _setLoading(false);
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

  void clear() {
    _matches = [];
    _errorMessage = null;
    notifyListeners();
  }
}