import '../entities/user_model.dart';

abstract class SessionRepository {
  Future<UserModel?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<void> signOut();
}
