// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/key_value_storage_service.dart';
import '../../infrastructure/datasources/auth_datasource_impl.dart' show AuthDataSourceImpl;

// Estado para manejar la autenticación
class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? userData;
  final String errorMessage;
  final String? userRole; // Añadimos el rol del usuario

  AuthState({
    this.isAuthenticated = false,
    this.userData,
    this.errorMessage = '',
    this.userRole,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? userData,
    String? errorMessage,
    String? userRole,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userData: userData ?? this.userData,
      errorMessage: errorMessage ?? this.errorMessage,
      userRole: userRole ?? this.userRole,
    );
  }
}

// Proveedor del estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSourceImpl authDataSource;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authDataSource,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  // Verificar estado de autenticación al iniciar
  Future<void> checkAuthStatus() async {
    final isAuthenticated = await authDataSource.isAuthenticated();
    
    if (isAuthenticated) {
      try {
        final email = await authDataSource.getCurrentUserEmail();
        if (email != null) {
          final userData = await authDataSource.getUserInfo(email);
          
          // Determinar el rol del usuario
          String userRole = 'usuario'; // Valor por defecto
          
          if (userData['tipo_usuario'] != null) {
            userRole = userData['tipo_usuario'];
          }
          
          // Guardar el rol en el almacenamiento seguro
          await keyValueStorageService.setKeyValue('user_role', userRole);
          
          state = state.copyWith(
            isAuthenticated: true,
            userData: userData,
            userRole: userRole,
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
      await authDataSource.login(email, password);
      
      final userData = await authDataSource.getUserInfo(email);
      
      // Determinar el rol del usuario
      String userRole = 'usuario'; // Valor por defecto
      
      if (userData['tipo_usuario'] != null) {
        userRole = userData['tipo_usuario'];
      }
      
      // Guardar el rol en el almacenamiento seguro
      await keyValueStorageService.setKeyValue('user_role', userRole);
      
      state = state.copyWith(
        isAuthenticated: true,
        userData: userData,
        userRole: userRole,
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
    return state.userRole ?? 'usuario';
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
      await authDataSource.register(
        email: email,
        password: password,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        telefono: telefono,
      );
      
      final userData = await authDataSource.getUserInfo(email);
      
      // Al registrarse, el rol por defecto es 'usuario'
      const userRole = 'usuario';
      
      // Guardar el rol en el almacenamiento seguro
      await keyValueStorageService.setKeyValue('user_role', userRole);
      
      state = state.copyWith(
        isAuthenticated: true,
        userData: userData,
        userRole: userRole,
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
  // In AuthNotifier.logout()
Future<void> logout() async {
  print('Logout method called');
  try {
    await authDataSource.logout();
    await keyValueStorageService.removeKey('user_role');
    
    print('Logout successful');
    state = AuthState();
  } catch (e) {
    print('Error during logout: $e');
    state = state.copyWith(
      errorMessage: e.toString(),
    );
  }
}
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = Supabase.instance.client;
  final keyValueStorageService = ref.watch(keyValueStorageProvider);
  
  final authDataSource = AuthDataSourceImpl(supabaseClient);
  
  return AuthNotifier(
    authDataSource: authDataSource,
    keyValueStorageService: keyValueStorageService,
  );
});

// Creamos un provider para el SupabaseClient que podrás usar en tu aplicación
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});