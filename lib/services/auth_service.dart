import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_runtime.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;

  const AuthUser({required this.uid, this.email, this.displayName});
}

class AuthService {
  static const _fallbackUidKey = 'fallback_uid';
  static const _fallbackEmailKey = 'fallback_email';
  static const _fallbackNameKey = 'fallback_name';
  static const _fallbackPhotoKey = 'fallback_photo';

  Future<AuthUser?> getCurrentUser() async {
    if (FirebaseRuntime.isAvailable) {
      final u = FirebaseAuth.instance.currentUser;
      if (u == null) return null;
      return AuthUser(uid: u.uid, email: u.email, displayName: u.displayName);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_fallbackUidKey);
      if (uid == null) return null;
      return AuthUser(
        uid: uid,
        email: prefs.getString(_fallbackEmailKey),
        displayName: prefs.getString(_fallbackNameKey),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isSignedIn() async => (await getCurrentUser()) != null;

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (FirebaseRuntime.isAvailable) {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final u = cred.user!;
      return AuthUser(uid: u.uid, email: u.email, displayName: u.displayName);
    }
    final prefs = await SharedPreferences.getInstance();
    final uid = 'local-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_fallbackUidKey, uid);
    await prefs.setString(_fallbackEmailKey, email);
    await prefs.setString(_fallbackNameKey, email.split('@').first);
    return AuthUser(uid: uid, email: email, displayName: email.split('@').first);
  }

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (FirebaseRuntime.isAvailable) {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      final u = FirebaseAuth.instance.currentUser!;
      return AuthUser(uid: u.uid, email: u.email, displayName: name);
    }
    final prefs = await SharedPreferences.getInstance();
    final uid = 'local-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_fallbackUidKey, uid);
    await prefs.setString(_fallbackEmailKey, email);
    await prefs.setString(_fallbackNameKey, name);
    return AuthUser(uid: uid, email: email, displayName: name);
  }

  Future<AuthUser> signInWithGoogle() async {
    if (FirebaseRuntime.isAvailable) {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final u = cred.user!;
      return AuthUser(uid: u.uid, email: u.email, displayName: u.displayName);
    }
    final prefs = await SharedPreferences.getInstance();
    final uid = 'local-google-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_fallbackUidKey, uid);
    await prefs.setString(_fallbackEmailKey, 'local.google@mindheaven');
    await prefs.setString(_fallbackNameKey, 'Google User');
    return const AuthUser(uid: 'local-google', email: 'local.google@mindheaven');
  }

  Future<AuthUser> signInAnonymously() async {
    if (FirebaseRuntime.isAvailable) {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      final u = cred.user!;
      return AuthUser(uid: u.uid, email: u.email, displayName: u.displayName);
    }
    final prefs = await SharedPreferences.getInstance();
    final uid = 'local-anon-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_fallbackUidKey, uid);
    await prefs.setString(_fallbackNameKey, 'Guest User');
    return AuthUser(uid: uid, displayName: 'Guest User');
  }

  Future<void> updateDisplayName(String name) async {
    if (FirebaseRuntime.isAvailable) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No signed-in user');
      await user.updateDisplayName(name.trim());
      await user.reload();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fallbackNameKey, name.trim());
  }

  Future<void> updateEmail(String email) async {
    if (FirebaseRuntime.isAvailable) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No signed-in user');
      await user.verifyBeforeUpdateEmail(email.trim());
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fallbackEmailKey, email.trim());
  }

  Future<void> updatePhotoUrl(String url) async {
    if (FirebaseRuntime.isAvailable) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No signed-in user');
      await user.updatePhotoURL(url.trim());
      await user.reload();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fallbackPhotoKey, url.trim());
  }

  Future<String?> getPhotoUrl() async {
    if (FirebaseRuntime.isAvailable) {
      return FirebaseAuth.instance.currentUser?.photoURL;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fallbackPhotoKey);
  }

  Future<void> resetPassword(String email) async {
    if (FirebaseRuntime.isAvailable) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }

  Future<void> signOut() async {
    if (FirebaseRuntime.isAvailable) {
      await FirebaseAuth.instance.signOut();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fallbackUidKey);
    await prefs.remove(_fallbackEmailKey);
    await prefs.remove(_fallbackNameKey);
    await prefs.remove(_fallbackPhotoKey);
  }
}

