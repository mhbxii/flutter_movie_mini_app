import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_auth_service.dart';
import '../data/services/storage_service.dart';
import '../core/exceptions/auth_exceptions.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final StorageService _storageService = StorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  // Check auth state on app start
  Future<void> checkAuthState() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // Signup
  Future<bool> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    File? photoFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      String? photoUrl;

      // Upload photo first if provided
      if (photoFile != null) {
        // Create temp user ID for storage (will use actual uid after auth)
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        photoUrl = await _storageService.uploadProfilePhoto(photoFile, tempId);
      }

      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        age: age,
        photoUrl: photoUrl,
      );

      // If photo was uploaded with temp ID, re-upload with actual uid
      if (photoFile != null && _currentUser != null) {
        photoUrl = await _storageService.uploadProfilePhoto(photoFile, _currentUser!.uid);
        // Update user doc with correct photo URL
        // (handled in next phase when we add update methods)
      }

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _clearError();
    notifyListeners();
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