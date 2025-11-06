import 'package:firebase_auth/firebase_auth.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Sign up new user
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    String? photoUrl,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final now = DateTime.now();
      final user = UserModel(
        uid: userCred.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        photoUrl: photoUrl,
        role: 'user',
        isActive: true,
        favoriteMovies: [],
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.createDocument('users', user.uid, user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userData = await _firestore.getDocument('users', userCred.user!.uid);
      
      if (userData == null) throw UserNotFoundException();

      final user = UserModel.fromMap(userData);
     
      // Check if user is disabled
      if (!user.isActive) {
        await _auth.signOut();
        throw UserDisabledException();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userData = await _firestore.getDocument('users', currentUser.uid);
    if (userData == null) return null;

    return UserModel.fromMap(userData);
  }

  // Handle Firebase Auth exceptions
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return WeakPasswordException();
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'invalid-email':
        return InvalidEmailException();
      case 'user-not-found':
      case 'wrong-password':
        return WrongPasswordException();
      case 'network-request-failed':
        return NetworkException();
      default:
        return AuthException(e.message ?? 'Authentication failed');
    }
  }
}