// lib/features/auth/infrastructure/datasources/auth_datasource_impl.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Definir enum para tipos de errores de autenticación
enum AuthErrorType {
  userNotFound,
  incorrectPassword,
  emailAlreadyExists,
  networkError,
  serverError,
  unknown
}

// Clase personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final AuthErrorType errorType;

  AuthException(this.message, this.errorType);

  @override
  String toString() => message;
}

// Constantes para los roles de usuario
class UserRoles {
  static const String administrador = 'administrador';
  static const String operador = 'operador';
  static const String usuario = 'usuario';
}

class AuthDataSourceImpl {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthDataSourceImpl(this._supabaseClient);

  // Generar un salt aleatorio para mayor seguridad
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Hash de contraseña mejorado con salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Hash de contraseña antiguo (para compatibilidad)
  String _oldHashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Login de usuario mejorado con mensajes de error específicos
  Future<void> login(String email, String password) async {
    try {
      print("Iniciando login para: $email");
      
      // Primero verificar si el usuario existe en la base de datos
      final userExists = await _supabaseClient
          .from('usuario')
          .select('id')
          .eq('correo', email)
          .maybeSingle();
      
      print("Usuario existe: ${userExists != null}");
      
      if (userExists == null) {
        throw AuthException(
          'No se encontró una cuenta con el correo $email',
          AuthErrorType.userNotFound
        );
      }
      
      // Si el usuario existe, verificamos la contraseña
      final salt = await _getUserSalt(email);
      print("Salt obtenido: ${salt ?? 'NULL'}");
      
      String hashedPassword;
      
      if (salt != null && salt.isNotEmpty) {
        hashedPassword = _hashPassword(password, salt);
        print("Usando password con salt: $hashedPassword");
      } else {
        // Método antiguo para compatibilidad
        hashedPassword = _oldHashPassword(password);
        print("Usando password sin salt: $hashedPassword");
      }
      
      // Verificar la contraseña
      final userWithPassword = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .eq('password', hashedPassword)
          .maybeSingle();
      
      print("Verificación de contraseña: ${userWithPassword != null}");
      
      if (userWithPassword == null) {
        throw AuthException(
          'La contraseña es incorrecta para el correo $email',
          AuthErrorType.incorrectPassword
        );
      }
      
      // Obtener información completa del usuario
      final userData = await getUserInfo(email);
      
      // Guardar la sesión en almacenamiento seguro
      await _secureStorage.write(key: 'user_email', value: email);
      await _secureStorage.write(key: 'user_id', value: userData['id'].toString());
      await _secureStorage.write(key: 'user_role', value: userData['role']);
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      
      // Actualizar estado de sesión en la base de datos
      await _supabaseClient
          .from('usuario')
          .update({
            'is_logged_in': true,
            'last_login': DateTime.now().toIso8601String()
          })
          .eq('id', userData['id']);
      
      // Registrar intento de login exitoso
      await _registerLoginAttempt(email, true);
      
    } catch (e) {
      print("Error en login: $e");
      
      // Registrar intento de login fallido
      if (e is! AuthException || e.errorType != AuthErrorType.userNotFound) {
        await _registerLoginAttempt(email, false);
      }
      
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException(
          'Error en el inicio de sesión: $e',
          AuthErrorType.unknown
        );
      }
    }
  }

  // Obtener el salt del usuario
  Future<String?> _getUserSalt(String email) async {
    try {
      final userData = await _supabaseClient
          .from('usuario')
          .select('salt')
          .eq('correo', email)
          .single();
      
      return userData['salt'];
    } catch (e) {
      print("Error al obtener salt: $e");
      return null;
    }
  }

  // Registrar intento de login
  Future<void> _registerLoginAttempt(String email, bool success) async {
    try {
      await _supabaseClient
          .from('login_attempts')
          .insert({
            'correo': email,
            'ip_address': 'app_client', // Idealmente usaríamos la IP real
            'success': success,
          });
    } catch (e) {
      print("Error al registrar intento de login: $e");
      // Ignoramos errores aquí para no interferir con el flujo principal
    }
  }

  // Registro de usuario con mensajes específicos
  Future<void> register({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existingUser = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .maybeSingle();
      
      if (existingUser != null) {
        throw AuthException(
          'El correo $email ya está registrado. Intenta iniciar sesión o usa otro correo.',
          AuthErrorType.emailAlreadyExists
        );
      }
      
      // Generar salt y hash de contraseña
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      
      print("Registrando usuario con salt: $salt");
      print("Password hasheado: $hashedPassword");
      
      // Insertar el nuevo usuario
      final response = await _supabaseClient
          .from('usuario')
          .insert({
            'correo': email,
            'password': hashedPassword,
            'salt': salt,
            'nombre': nombre,
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'telefono': telefono,
            'tipo_usuario': UserRoles.usuario,
            'password_version': 2, // Versión 2 = con salt
          })
          .select()
          .single();
      
      // Iniciar sesión automáticamente
      await _secureStorage.write(key: 'user_email', value: email);
      await _secureStorage.write(key: 'user_id', value: response['id'].toString());
      await _secureStorage.write(key: 'user_role', value: UserRoles.usuario);
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      
      // Actualizar estado de sesión en la base de datos
      await _supabaseClient
          .from('usuario')
          .update({
            'is_logged_in': true,
            'last_login': DateTime.now().toIso8601String()
          })
          .eq('id', response['id']);
      
    } catch (e) {
      print("Error en registro: $e");
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException(
          'Error en el registro: $e',
          AuthErrorType.unknown
        );
      }
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      // Obtener el email actual antes de borrar la sesión
      final email = await getCurrentUserEmail();
      final userId = await _secureStorage.read(key: 'user_id');
      
      if (email != null && userId != null) {
        // Actualizar is_logged_in en la base de datos
        await _supabaseClient
            .from('usuario')
            .update({'is_logged_in': false})
            .eq('id', userId);
      }
      
      // Eliminar datos de sesión local
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'user_role');
      await _secureStorage.delete(key: 'is_logged_in');
    } catch (e) {
      print("Error en logout: $e");
      throw AuthException(
        'Error al cerrar sesión: $e',
        AuthErrorType.unknown
      );
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String email) async {
    try {
      final userData = await _supabaseClient
          .from('usuario')
          .select('*, administrador(*), operador(*)')
          .eq('correo', email)
          .single();
      
      // Normalizar el rol del usuario
      String userRole = userData['tipo_usuario'] ?? UserRoles.usuario;
      
      
      // Alternativa: determinar el rol basado en relaciones
      if (userData['administrador'] != null && userData['administrador'] is Map && userData['administrador'].isNotEmpty) {
        userRole = UserRoles.administrador;
      }
      else if (userData['operador'] != null && userData['operador'] is Map && userData['operador'].isNotEmpty) {
        userRole = UserRoles.operador;
      }
      
      // Añadir el rol explícitamente a los datos del usuario
      userData['role'] = userRole;
      
      return userData;
    } catch (e) {
      print("Error al obtener info de usuario: $e");
      throw AuthException(
        'Error al obtener información del usuario: $e',
        AuthErrorType.unknown
      );
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final isLoggedIn = await _secureStorage.read(key: 'is_logged_in');
    return isLoggedIn == 'true';
  }

  // Obtener el email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    return await _secureStorage.read(key: 'user_email');
  }

  // Obtener el rol del usuario actual
  Future<String?> getCurrentUserRole() async {
    return await _secureStorage.read(key: 'user_role');
  }

  // Método para regenerar salt y actualizar contraseña (útil para reset de contraseña)
  Future<void> updatePassword(String email, String newPassword) async {
    try {
      // Generar nuevo salt
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);
      
      // Actualizar en la base de datos
      await _supabaseClient
          .from('usuario')
          .update({
            'password': hashedPassword,
            'salt': salt,
            'password_version': 2,
            'requires_password_reset': false,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('correo', email);
    } catch (e) {
      print("Error al actualizar contraseña: $e");
      throw AuthException(
        'Error al actualizar contraseña: $e',
        AuthErrorType.unknown
      );
    }
  }

  // Crear un nuevo administrador
  Future<void> createAdmin({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existingUser = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .maybeSingle();
      
      if (existingUser != null) {
        throw AuthException(
          'El correo $email ya está registrado',
          AuthErrorType.emailAlreadyExists
        );
      }
      
      // Generar salt y hash de contraseña
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      
      // Iniciar una transacción para crear usuario y administrador
      // Primero crear el usuario
      final userResponse = await _supabaseClient
          .from('usuario')
          .insert({
            'correo': email,
            'password': hashedPassword,
            'salt': salt,
            'nombre': nombre,
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'telefono': telefono,
            'tipo_usuario': UserRoles.administrador,
            'password_version': 2,
          })
          .select()
          .single();
      
      // Luego crear el registro en la tabla administrador
      await _supabaseClient
          .from('administrador')
          .insert({
            'usuario_id': userResponse['id'],
          });
      
    } catch (e) {
      print("Error al crear administrador: $e");
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException(
          'Error al crear administrador: $e',
          AuthErrorType.unknown
        );
      }
    }
  }

  // Crear un nuevo operador
  Future<void> createOperador({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existingUser = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .maybeSingle();
      
      if (existingUser != null) {
        throw AuthException(
          'El correo $email ya está registrado',
          AuthErrorType.emailAlreadyExists
        );
      }
      
      // Generar salt y hash de contraseña
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      
      // Iniciar una transacción para crear usuario y operador
      // Primero crear el usuario
      final userResponse = await _supabaseClient
          .from('usuario')
          .insert({
            'correo': email,
            'password': hashedPassword,
            'salt': salt,
            'nombre': nombre,
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'telefono': telefono,
            'tipo_usuario': UserRoles.operador,
            'password_version': 2,
            'licencia': 'PENDIENTE', // Campo requerido para operadores
          })
          .select()
          .single();
      
      // Luego crear el registro en la tabla operador
      await _supabaseClient
          .from('operador')
          .insert({
            'usuario_id': userResponse['id'],
            'licencia': 'PENDIENTE', // Campo requerido para operadores
          });
      
    } catch (e) {
      print("Error al crear operador: $e");
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException(
          'Error al crear operador: $e',
          AuthErrorType.unknown
        );
      }
    }
  }
}