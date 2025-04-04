// lib/password/password_migration_util.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

// Clase de utilidad para migrar contraseñas a formato hash con salt
class PasswordMigrationUtil {
  final SupabaseClient _supabaseClient;
  
  PasswordMigrationUtil(this._supabaseClient);

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

  // La función de hash antigua (para compatibilidad)
  String _oldHashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Actualiza todas las contraseñas de los usuarios admin/operador a formato hash con salt
  Future<void> migrateAdminOperatorPasswords() async {
    try {
      // Obtener todos los usuarios que sean admin o administrador o operador
      final usuarios = await _supabaseClient
          .from('usuario')
          .select('id, correo, password, tipo_usuario, salt')
          .or('tipo_usuario.eq.admin,tipo_usuario.eq.administrador,tipo_usuario.eq.operador');
      
      // Convertir a lista de mapas para facilitar el procesamiento
      final allUsers = List<Map<String, dynamic>>.from(usuarios);
      
      int migrados = 0;
      int yaActualizados = 0;
      
      // Para cada usuario, verificar si la contraseña ya tiene salt
      for (var user in allUsers) {
        final String userId = user['id'].toString();
        final String currentPassword = user['password'];
        final String? currentSalt = user['salt'];
        
        // Si no tiene salt, actualizar al nuevo formato
        if (currentSalt == null || currentSalt.isEmpty) {
          // Verificar si la contraseña está en formato antiguo (solo SHA-256)
          if (_looksLikeHash(currentPassword)) {
            // Es una contraseña hash sin salt, actualizar a nuevo formato no es posible directamente
            // Tendríamos que establecer una contraseña temporal
            final String newSalt = _generateSalt();
            final String tempPassword = 'Temporal1234'; // Contraseña temporal que cumple requisitos
            final String hashedTempPassword = _hashPassword(tempPassword, newSalt);
            
            // Actualizar en la base de datos
            await _supabaseClient
                .from('usuario')
                .update({
                  'password': hashedTempPassword,
                  'salt': newSalt,
                  'requires_password_reset': true, // Indicar que necesita reiniciar contraseña
                })
                .eq('id', userId);
                
            print('Usuario ${user['correo']} migrado con contraseña temporal.');
            migrados++;
          } else {
            // Es una contraseña en texto plano, podemos actualizarla directamente
            final String newSalt = _generateSalt();
            final String hashedPassword = _hashPassword(currentPassword, newSalt);
            
            // Actualizar en la base de datos
            await _supabaseClient
                .from('usuario')
                .update({
                  'password': hashedPassword,
                  'salt': newSalt,
                })
                .eq('id', userId);
                
            print('Usuario ${user['correo']} migrado correctamente.');
            migrados++;
          }
        } else {
          print('Usuario ${user['correo']} ya tiene salt, no requiere migración.');
          yaActualizados++;
        }
      }
      
      print('Migración completada: $migrados usuarios migrados, $yaActualizados ya tenían salt.');
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