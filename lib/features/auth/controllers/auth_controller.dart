import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarl_mobile_app/common/services/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseDatabase.instance);
});

class AuthState {
  final bool isLoggedIn;
  final bool mustChangePassword;
  final String username;
  final String firstName;
  final String lastName;
  final String? error;

  const AuthState({
    required this.isLoggedIn,
    required this.mustChangePassword,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.error,
  });

  factory AuthState.initial() => const AuthState(
        isLoggedIn: false,
        mustChangePassword: false,
        username: '',
        firstName: '',
        lastName: '',
      );

  AuthState copyWith({
    bool? isLoggedIn,
    bool? mustChangePassword,
    String? username,
    String? firstName,
    String? lastName,
    String? error,
  }) => AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        error: error,
      );
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.initial()) {
    _loadPersistent();
  }

  final Ref _ref;

  Future<void> _loadPersistent() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool('is_logged_in') ?? false;
    final username = prefs.getString('username') ?? '';
    final firstName = prefs.getString('firstname') ?? '';
    final lastName = prefs.getString('lastname') ?? '';
    if (isLogged && username.isNotEmpty) {
      state = state.copyWith(
        isLoggedIn: true,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
    }
  }

  Future<void> login(String username, String password) async {
    if (Firebase.apps.isEmpty) {
      state = state.copyWith(error: 'Firebase is not initialized on this platform.');
      return;
    }
    try {
      final repo = _ref.read(authRepositoryProvider);
      state = state.copyWith(error: null);
      final record = await repo.findUserByUsername(username);
      if (record == null) {
        state = state.copyWith(error: 'Invalid Username or Password.', isLoggedIn: false);
        return;
      }
      if (record.password != password) {
        state = state.copyWith(error: 'Invalid Username or Password.', isLoggedIn: false);
        return;
      }
      if (record.role != 'Parent') {
        state = state.copyWith(error: 'Only Parent accounts are allowed to log in.', isLoggedIn: false);
        return;
      }
      if (record.mustChangePassword) {
        state = state.copyWith(
          mustChangePassword: true,
          username: record.username,
          firstName: record.firstName,
          lastName: record.lastName,
        );
        return;
      }
      state = state.copyWith(
        isLoggedIn: true,
        mustChangePassword: false,
        username: record.username,
        firstName: record.firstName,
        lastName: record.lastName,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('username', record.username);
      await prefs.setString('firstname', record.firstName);
      await prefs.setString('lastname', record.lastName);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoggedIn: false);
    }
  }

  Future<bool> changePassword(String username, String newPassword) async {
    final repo = _ref.read(authRepositoryProvider);
    final user = await repo.findUserByUsername(username);
    if (user == null) return false;
    await repo.updatePasswordAndClearFlag(user.uid, newPassword);
    state = state.copyWith(mustChangePassword: false, isLoggedIn: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('username', user.username);
    await prefs.setString('firstname', user.firstName);
    await prefs.setString('lastname', user.lastName);
    return true;
  }

  Future<void> logout() async {
    state = AuthState.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('username');
    await prefs.remove('firstname');
    await prefs.remove('lastname');
  }
}
