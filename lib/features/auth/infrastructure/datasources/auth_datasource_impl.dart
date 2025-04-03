import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthDataSourceImpl {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthDataSourceImpl(this._supabaseClient);

  // Hash password para almacenamiento seguro
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Login de usuario
  Future<void> login(String email, String password) async {
    try {
      // Hash la contraseña
      final hashedPassword = _hashPassword(password);
      
      // Buscar el usuario en la base de datos
      final response = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .eq('password', hashedPassword)
          .single();
      
      if (response.isEmpty) {
        throw Exception('Credenciales inválidas');
      }
      
      // Guardar la sesión en almacenamiento seguro
      await _secureStorage.write(key: 'user_email', value: email);
      await _secureStorage.write(key: 'user_id', value: response['id'].toString());
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      
    } catch (e) {
      throw Exception('Error en el inicio de sesión: $e');
    }
  }

  // Registro de usuario
  Future<void> register({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    try {
      // Hash la contraseña
      final hashedPassword = _hashPassword(password);
      
      // Verificar si el usuario ya existe
      final existingUser = await _supabaseClient
          .from('usuario')
          .select()
          .eq('correo', email)
          .maybeSingle();
      
      if (existingUser != null) {
        throw Exception('El correo electrónico ya está registrado');
      }
      
      // Insertar el nuevo usuario
      final response = await _supabaseClient
          .from('usuario')
          .insert({
            'correo': email,
            'password': hashedPassword,
            'nombre': nombre,
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'telefono': telefono,
            'tipo_usuario': 'usuario',
          })
          .select()
          .single();
      
      // Iniciar sesión automáticamente
      await _secureStorage.write(key: 'user_email', value: email);
      await _secureStorage.write(key: 'user_id', value: response['id'].toString());
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      
    } catch (e) {
      throw Exception('Error en el registro: $e');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'is_logged_in');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String email) async {
    try {
      final userData = await _supabaseClient
          .from('usuario')
          .select('*, administrador(*), operador(*)')
          .eq('correo', email)
          .single();
      
      // Enriquecer los datos con el rol explícito
      String userRole = userData['tipo_usuario'] ?? 'usuario';
      
      // Alternativa: determinar el rol basado en relaciones
      // Si este usuario tiene una entrada en la tabla administrador, es un administrador
      if (userData['administrador'] != null && userData['administrador'] is Map && userData['administrador'].isNotEmpty) {
        userRole = 'administrador';
      }
      // Si tiene una entrada en operador, es un operador
      else if (userData['operador'] != null && userData['operador'] is Map && userData['operador'].isNotEmpty) {
        userRole = 'operador';
      }
      
      // Añadir el rol explícitamente a los datos del usuario
      userData['role'] = userRole;
      
      return userData;
    } catch (e) {
      throw Exception('Error al obtener información del usuario: $e');
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final isLoggedIn = await _secureStorage.read(key: 'is_logged_in');
    return isLoggedIn == 'true';
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    // Esta implementación es solo para mantener la compatibilidad con el resto del código
    // Realmente estamos usando nuestro propio sistema de autenticación
    return null;
  }
  
  // Obtener el email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    return await _secureStorage.read(key: 'user_email');
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
    // Hash la contraseña
    final hashedPassword = _hashPassword(password);
    
    // Verificar si el usuario ya existe
    final existingUser = await _supabaseClient
        .from('usuario')
        .select()
        .eq('correo', email)
        .maybeSingle();
    
    if (existingUser != null) {
      throw Exception('El correo electrónico ya está registrado');
    }
    
    // Iniciar una transacción para crear usuario y administrador
    // Primero crear el usuario
    final userResponse = await _supabaseClient
        .from('usuario')
        .insert({
          'correo': email,
          'password': hashedPassword,
          'nombre': nombre,
          'apellido_paterno': apellidoPaterno,
          'apellido_materno': apellidoMaterno,
          'telefono': telefono,
          'tipo_usuario': 'administrador',
        })
        .select()
        .single();
    
    // Luego crear el registro en la tabla administrador
    await _supabaseClient
        .from('administrador')
        .insert({
          'usuario_id': userResponse['id'],
          // Añadir otros campos necesarios para la tabla administrador
        });
    
  } catch (e) {
    throw Exception('Error al crear administrador: $e');
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
    // Hash la contraseña
    final hashedPassword = _hashPassword(password);
    
    // Verificar si el usuario ya existe
    final existingUser = await _supabaseClient
        .from('usuario')
        .select()
        .eq('correo', email)
        .maybeSingle();
    
    if (existingUser != null) {
      throw Exception('El correo electrónico ya está registrado');
    }
    
    // Iniciar una transacción para crear usuario y operador
    // Primero crear el usuario
    final userResponse = await _supabaseClient
        .from('usuario')
        .insert({
          'correo': email,
          'password': hashedPassword,
          'nombre': nombre,
          'apellido_paterno': apellidoPaterno,
          'apellido_materno': apellidoMaterno,
          'telefono': telefono,
          'tipo_usuario': 'operador',
        })
        .select()
        .single();
    
    // Luego crear el registro en la tabla operador
    await _supabaseClient
        .from('operador')
        .insert({
          'usuario_id': userResponse['id'],
          // Añadir otros campos necesarios para la tabla operador
        });
    
  } catch (e) {
    throw Exception('Error al crear operador: $e');
  }
}
}