// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_app/core/di/dependency_injection.dart';
import 'package:maps_app/features/auth/domain/entities/Usuario.dart';
import 'package:maps_app/services/key_value_storage_service.dart';
import 'package:maps_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/is_authenticated_usecase.dart';
import 'package:maps_app/services/key_value_storage_service.dart' as di;

// Estado para manejar la autenticación
class AuthState {
  final bool isAuthenticated;
  final Usuario? user;
  final String errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.errorMessage = '',
  });

  String? get userRole => user?.rol;

  AuthState copyWith({
    bool? isAuthenticated,
    Usuario? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Proveedor del estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;
  final KeyValueStorageService _keyValueStorageService;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
    required KeyValueStorageService keyValueStorageService,
  }) : 
    _loginUseCase = loginUseCase,
    _registerUseCase = registerUseCase,
    _logoutUseCase = logoutUseCase,
    _getCurrentUserUseCase = getCurrentUserUseCase,
    _isAuthenticatedUseCase = isAuthenticatedUseCase,
    _keyValueStorageService = keyValueStorageService,
    super(AuthState()) {
    checkAuthStatus();
  }

  // Verificar estado de autenticación al iniciar
  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _isAuthenticatedUseCase.execute();
    
    if (isAuthenticated) {
      try {
        final user = await _getCurrentUserUseCase.execute();
        
        if (user != null) {
          // Guardar el rol en el almacenamiento seguro
          await _keyValueStorageService.setKeyValue('user_role', user.rol);
          
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
          );
        }
      } catch (e) {
        logout();
      }
    }
  }

  // Iniciar sesión
  Future<void> loginUser(String email, String password) async {
    try {
      final user = await _loginUseCase.execute(email, password);
      
      // Guardar el rol en el almacenamiento seguro
      await _keyValueStorageService.setKeyValue('user_role', user.rol);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // Obtener el rol del usuario actual
  String getUserRole() {
    return state.user?.rol ?? 'usuario';
  }

  // Registrar usuario
  Future<void> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    try {
      final user = await _registerUseCase.execute(
        email: email,
        password: password,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        telefono: telefono,
      );
      
      // Guardar el rol en el almacenamiento seguro
      await _keyValueStorageService.setKeyValue('user_role', user.rol);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _logoutUseCase.execute();
      await _keyValueStorageService.removeKey('user_role');
      
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isAuthenticatedUseCase = ref.watch(isAuthenticatedUseCaseProvider);
  final keyValueStorageService = ref.watch(di.keyValueStorageProvider);
  
  return AuthNotifier(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    isAuthenticatedUseCase: isAuthenticatedUseCase,
    keyValueStorageService: keyValueStorageService,
  );
});