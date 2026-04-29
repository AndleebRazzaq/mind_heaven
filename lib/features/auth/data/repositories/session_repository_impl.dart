import '../../../../services/auth_service.dart';
import '../../domain/entities/user_model.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final AuthService _authService;

  SessionRepositoryImpl(this._authService);

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return null;
    return UserModel.fromAuthUser(user);
  }

  @override
  Future<bool> isSignedIn() => _authService.isSignedIn();

  @override
  Future<void> signOut() => _authService.signOut();
}
