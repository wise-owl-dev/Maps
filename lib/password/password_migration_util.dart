import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

// Clase de utilidad para migrar contraseñas a formato hash
class PasswordMigrationUtil {
  final SupabaseClient _supabaseClient;
  
  PasswordMigrationUtil(this._supabaseClient);

  // La misma función de hash usada en AuthDataSourceImpl
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Actualiza todas las contraseñas de los usuarios admin/operador a formato hash
  Future<void> migrateAdminOperatorPasswords() async {
    try {
      // Primero obtener todos los usuarios admin
      final admins = await _supabaseClient
          .from('usuario')
          .select('id, correo, password, tipo_usuario')
          .eq('tipo_usuario', 'admin');
      
      // Luego obtener todos los usuarios administrador
      final administradores = await _supabaseClient
          .from('usuario')
          .select('id, correo, password, tipo_usuario')
          .eq('tipo_usuario', 'admin');
      
      // Finalmente obtener todos los usuarios operador
      final operadores = await _supabaseClient
          .from('usuario')
          .select('id, correo, password, tipo_usuario')
          .eq('tipo_usuario', 'operador');
      
      // Combinar todos los resultados
      List<Map<String, dynamic>> allUsers = [];
      
      if (admins != null) {
        allUsers.addAll(List<Map<String, dynamic>>.from(admins));
      }
      
      if (administradores != null) {
        allUsers.addAll(List<Map<String, dynamic>>.from(administradores));
      }
      
      if (operadores != null) {
        allUsers.addAll(List<Map<String, dynamic>>.from(operadores));
      }
      
      // Para cada usuario, verificar si la contraseña ya está en hash (aproximadamente)
      // y actualizarla si no lo parece
      for (var user in allUsers) {
        // Las contraseñas hash SHA-256 tienen 64 caracteres hex
        // Si la contraseña es más corta, probablemente esté en texto plano
        String currentPassword = user['password'];
        if (currentPassword.length != 64 || !_looksLikeHash(currentPassword)) {
          // Convertir a hash y actualizar
          String hashedPassword = _hashPassword(currentPassword);
          
          // Actualizar en la base de datos
          final updateResult = await _supabaseClient
              .from('usuario')
              .update({'password': hashedPassword})
              .eq('id', user['id']);
          
          print('Contraseña actualizada para usuario: ${user['correo']} (${user['tipo_usuario']})');
        } else {
          print('La contraseña de ${user['correo']} ya parece estar en formato hash');
        }
      }
      
      print('Migración de contraseñas completada');
    } catch (e) {
      print('Error durante la migración de contraseñas: $e');
      throw Exception('Error durante la migración de contraseñas: $e');
    }
  }
  
  // Comprueba si una cadena parece ser un hash SHA-256 (64 caracteres hexadecimales)
  bool _looksLikeHash(String str) {
    return RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(str);
  }
}