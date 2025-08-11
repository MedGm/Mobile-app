import 'package:firebase_database/firebase_database.dart';

class AuthUserRecord {
  final String uid;
  final String username;
  final String password; // plaintext to match current schema
  final bool mustChangePassword;
  final String role;
  final String firstName;
  final String lastName;

  AuthUserRecord({
    required this.uid,
    required this.username,
    required this.password,
    required this.mustChangePassword,
    required this.role,
    required this.firstName,
    required this.lastName,
  });
}

class AuthRepository {
  AuthRepository(this._db);
  final FirebaseDatabase _db;

  Future<AuthUserRecord?> findUserByUsername(String username) async {
    final query = _db.ref('users').orderByChild('auth/username').equalTo(username);
    final snap = await query.get();
    if (!snap.exists) return null;
    final first = snap.children.first;
    final data = first.value as Map<dynamic, dynamic>;
    final auth = (data['auth'] as Map<dynamic, dynamic>?) ?? {};
    return AuthUserRecord(
      uid: (data['uid'] ?? first.key ?? '') as String,
      username: (auth['username'] ?? '') as String,
      password: (auth['password'] ?? '') as String,
      mustChangePassword: (auth['mustChangePassword'] ?? false) as bool,
      role: (data['role'] ?? '') as String,
      firstName: (data['firstName'] ?? '') as String,
      lastName: (data['lastName'] ?? '') as String,
    );
  }

  Future<bool> validatePassword(String username, String inputPassword) async {
    final user = await findUserByUsername(username);
    if (user == null) return false;
    return user.password == inputPassword;
  }

  Future<void> updatePasswordAndClearFlag(String uid, String newPassword) async {
    final ref = _db.ref('users/$uid/auth');
    await ref.update({
      'password': newPassword,
      'mustChangePassword': false,
    });
  }
}
