import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/usecases/get_saved_token.dart';
import '../../domain/auth/usecases/login.dart';
import '../../domain/auth/usecases/logout.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required Login login,
    required Logout logout,
    required GetSavedToken getSavedToken,
  })  : _login = login,
        _logout = logout,
        _getSavedToken = getSavedToken,
        super(const AuthState(status: AuthStatus.unknown));

  final Login _login;
  final Logout _logout;
  final GetSavedToken _getSavedToken;

  Future<void> checkAuth() async {
    final token = await _getSavedToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } else {
      state = state.copyWith(status: AuthStatus.authenticated);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _login(
        username: username.trim(),
        password: password.trim(),
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _logout();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}
