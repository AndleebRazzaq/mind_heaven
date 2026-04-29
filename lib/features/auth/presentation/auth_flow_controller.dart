import '../domain/repositories/session_repository.dart';

class AuthFlowController {
  final SessionRepository _sessionRepository;

  AuthFlowController(this._sessionRepository);

  Future<void> signOut() => _sessionRepository.signOut();
}
