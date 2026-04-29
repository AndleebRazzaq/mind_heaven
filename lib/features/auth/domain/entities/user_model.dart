import '../../../../services/auth_service.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  const UserModel({required this.uid, this.email, this.displayName});

  factory UserModel.fromAuthUser(AuthUser user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
